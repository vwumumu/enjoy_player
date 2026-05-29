# Patches pub-cache Android Gradle files for AGP 9 compatibility.
# Run after `flutter pub get` when debug/release Android builds fail on older plugins.
$ErrorActionPreference = "Stop"

$pubCache = if ($env:PUB_CACHE) { $env:PUB_CACHE } else { Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev" }
if (-not (Test-Path $pubCache)) {
    Write-Error "Pub cache not found at $pubCache"
}

$inappWebViewGradle = Join-Path $pubCache "flutter_inappwebview_android-1.1.3\android\build.gradle"
if (Test-Path $inappWebViewGradle) {
    $text = Get-Content $inappWebViewGradle -Raw
    $updated = $text -replace "proguard-android\.txt", "proguard-android-optimize.txt"
    if ($updated -ne $text) {
        Set-Content -Path $inappWebViewGradle -Value $updated -NoNewline
        Write-Host "Patched $inappWebViewGradle (proguard-android-optimize.txt)"
    }
}

Write-Host "AGP 9 pub plugin patches applied."
