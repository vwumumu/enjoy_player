# Ensure Inno Setup 6 (iscc) is available for Windows installer builds.
$ErrorActionPreference = "Stop"

$iscc = Get-Command iscc -ErrorAction SilentlyContinue
if ($iscc) {
  Write-Host "Inno Setup compiler already on PATH: $($iscc.Source)"
  exit 0
}

$candidatePaths = @(
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 7\ISCC.exe",
  "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe"
)

foreach ($isccPath in $candidatePaths) {
  if (-not (Test-Path $isccPath)) { continue }
  $dir = Split-Path $isccPath -Parent
  Write-Host "Adding Inno Setup to PATH: $dir"
  if ($env:GITHUB_PATH) {
    echo "$dir" >> $env:GITHUB_PATH
  } else {
    $env:Path = "$dir;$env:Path"
  }
  exit 0
}

Write-Host "Installing Inno Setup 6 via Chocolatey..."
choco install innosetup -y --no-progress

$iscc = Get-Command iscc -ErrorAction SilentlyContinue
if (-not $iscc) {
  foreach ($isccPath in $candidatePaths) {
    if (-not (Test-Path $isccPath)) { continue }
    $dir = Split-Path $isccPath -Parent
    if ($env:GITHUB_PATH) { echo "$dir" >> $env:GITHUB_PATH }
    Write-Host "Inno Setup installed at $isccPath"
    exit 0
  }
  Write-Error "iscc not found after Inno Setup install."
  exit 1
}

Write-Host "Inno Setup compiler: $($iscc.Source)"
