# Map GITHUB_WORKSPACE to a short drive letter so MSBuild plugin paths stay under MAX_PATH.
# Self-hosted runners often use long paths like ...\_work\org\repo\ that break
# flutter_inappwebview_windows / media_kit native extract steps (MSB3491).
$ErrorActionPreference = 'Stop'

$shortRoot = 'W:'
$workspace = $env:GITHUB_WORKSPACE
if (-not $workspace) {
  throw 'GITHUB_WORKSPACE is not set'
}

$workspace = (Resolve-Path -LiteralPath $workspace).Path

if (Test-Path "${shortRoot}\") {
  subst "${shortRoot}" /d 2>$null
}

subst $shortRoot $workspace
if (-not (Test-Path "${shortRoot}\")) {
  throw "Failed to map ${shortRoot} to $workspace"
}

"GITHUB_WORKSPACE=$shortRoot" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
Write-Host "Mapped ${shortRoot} -> $workspace"
