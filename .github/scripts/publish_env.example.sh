# Copy to publish_env.local.sh (gitignored) and fill in values.
# Usage (Git Bash / macOS / Linux, from repo root):
#   source .github/scripts/publish_env.local.sh
#   bash .github/scripts/release.sh --platform windows --publish

export AWS_ACCESS_KEY_ID="<R2 access key id>"
export AWS_SECRET_ACCESS_KEY="<R2 secret access key>"
export AWS_DEFAULT_REGION="auto"
export AWS_ENDPOINT_URL_S3="https://<account-id>.r2.cloudflarestorage.com"
export PUBLISH_BUCKET="<r2-bucket-name>"
export PUBLISH_PREFIX="player"

export CLOUDFLARE_API_TOKEN="<token with Cache Purge>"
export CLOUDFLARE_ZONE_ID="<zone id for enjoy.bot>"
# export ENJOY_PLAYER_DL_BASE="https://dl.enjoy.bot/player"
# export SPARKLE_DSA_PRIV_PEM="/path/to/dsa_priv.pem"
