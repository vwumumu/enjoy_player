# Ensure NuGet.org is configured for WebView2 / flutter_inappwebview (self-hosted Windows).
$sources = nuget sources list 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Error "nuget is not on PATH. Install NuGet CLI on the self-hosted Windows runner."
  exit 1
}
if ($sources -match "api\.nuget\.org") {
  Write-Host "NuGet.org (v3) feed already configured."
} else {
  nuget sources Add -Name "nuget.org" -Source "https://api.nuget.org/v3/index.json" -NonInteractive
}
