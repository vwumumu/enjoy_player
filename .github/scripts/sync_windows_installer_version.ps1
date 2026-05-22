# Sync AppVersion in windows/installer/enjoy_player.iss from pubspec.yaml (semver only).
$ErrorActionPreference = "Stop"

$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -notmatch '(?m)^version:\s*([\d.]+)') {
  Write-Error "Could not parse version from pubspec.yaml"
  exit 1
}
$version = $Matches[1]

$issPath = "windows/installer/enjoy_player.iss"
$iss = Get-Content $issPath -Raw
$updated = $iss -replace '(?m)^AppVersion=.*$', "AppVersion=$version"

if ($updated -eq $iss) {
  Write-Error "AppVersion line not found in $issPath"
  exit 1
}

Set-Content -Path $issPath -Value $updated -NoNewline
Write-Host "Set AppVersion=$version in $issPath"
