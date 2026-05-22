# Ensure Inno Setup 6 (iscc) is available for Windows installer builds.
$ErrorActionPreference = "Stop"

$iscc = Get-Command iscc -ErrorAction SilentlyContinue
if ($iscc) {
  Write-Host "Inno Setup compiler already on PATH: $($iscc.Source)"
  exit 0
}

$defaultPath = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
if (Test-Path $defaultPath) {
  $dir = Split-Path $defaultPath -Parent
  Write-Host "Adding Inno Setup to PATH: $dir"
  echo "$dir" >> $env:GITHUB_PATH
  exit 0
}

Write-Host "Installing Inno Setup 6 via Chocolatey..."
choco install innosetup -y --no-progress

$iscc = Get-Command iscc -ErrorAction SilentlyContinue
if (-not $iscc) {
  if (Test-Path $defaultPath) {
    $dir = Split-Path $defaultPath -Parent
    echo "$dir" >> $env:GITHUB_PATH
    Write-Host "Inno Setup installed at $defaultPath"
    exit 0
  }
  Write-Error "iscc not found after Inno Setup install."
  exit 1
}

Write-Host "Inno Setup compiler: $($iscc.Source)"
