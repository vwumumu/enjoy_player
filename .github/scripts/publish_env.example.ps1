# Copy to publish_env.local.ps1 (gitignored) and fill in values.
# Usage (PowerShell, from repo root):
#   . .\.github\scripts\publish_env.local.ps1
#   bash .github/scripts/publish_player_release_to_s3.sh --windows-installer "build\windows\installer\EnjoyPlayerSetup-v0.1.0.exe"

$env:S3_ACCESS_KEY_ID = "<R2 access key id>"
$env:S3_SECRET_ACCESS_KEY = "<R2 secret access key>"
$env:S3_BUCKET = "<r2-bucket-name>"
$env:S3_ENDPOINT = "https://<account-id>.r2.cloudflarestorage.com"

# Optional
$env:S3_PREFIX = "player"
$env:CLOUDFLARE_API_TOKEN = "<token with Cache Purge>"
$env:CLOUDFLARE_ZONE_ID = "<zone id for enjoy.bot>"
