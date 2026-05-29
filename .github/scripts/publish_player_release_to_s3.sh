#!/usr/bin/env bash
# Upload versioned artifacts + regenerate feeds on dl.enjoy.bot (S3-compatible: R2, AWS, etc.).
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "${root}"

if [[ -z "${S3_ACCESS_KEY_ID:-}" || -z "${S3_SECRET_ACCESS_KEY:-}" ]]; then
  echo "Skipping publish: S3_ACCESS_KEY_ID / S3_SECRET_ACCESS_KEY not configured."
  exit 0
fi

# AWS CLI reads these names internally.
export AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${S3_REGION:-auto}"

bucket="${S3_BUCKET:-enjoy-dl}"
prefix="${S3_PREFIX:-player}"
version="${VERSION:-$("${root}/.github/scripts/read_pubspec_version.sh")}"
s3_base="s3://${bucket}/${prefix}/${version}"
public_base="${ENJOY_PLAYER_DL_BASE:-https://dl.enjoy.bot/player}"

if [[ -n "${S3_ENDPOINT:-}" ]]; then
  s3_endpoint=(--endpoint-url "${S3_ENDPOINT}")
else
  s3_endpoint=()
fi

# R2 and most S3-compatible stores: no object ACLs; public access via bucket domain.
s3_acl=()
if [[ ${#s3_endpoint[@]} -eq 0 ]]; then
  s3_acl=(--acl public-read)
fi

s3_cp() {
  aws s3 cp "$@" "${s3_endpoint[@]}" "${s3_acl[@]}"
}

purge_feed_cache() {
  if [[ -n "${CLOUDFLARE_API_TOKEN:-}" && -n "${CLOUDFLARE_ZONE_ID:-}" ]]; then
    curl -fsS -X POST \
      "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/purge_cache" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "{\"files\":[\"${public_base}/latest.json\",\"${public_base}/appcast.xml\"]}" \
      >/dev/null
    echo "Purged Cloudflare cache for feed URLs."
    return 0
  fi
  if [[ -n "${CLOUDFRONT_DISTRIBUTION_ID:-}" ]]; then
    aws cloudfront create-invalidation \
      --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
      --paths "/${prefix}/latest.json" "/${prefix}/appcast.xml" >/dev/null
    echo "Invalidated CloudFront paths for feeds."
  fi
}

feed_args=()
upload_files=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --windows-installer)
      upload_files+=("$2")
      feed_args+=(--windows-installer "$2")
      shift 2
      ;;
    --macos-zip)
      upload_files+=("$2")
      feed_args+=(--macos-zip "$2")
      shift 2
      ;;
    --android-apk)
      upload_files+=("$3")
      feed_args+=(--android-apk "$2" "$3")
      shift 3
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ${#upload_files[@]} -eq 0 ]]; then
  echo "No artifacts to publish."
  exit 0
fi

for f in "${upload_files[@]}"; do
  if [[ ! -f "${f}" ]]; then
    echo "::error::Missing artifact: ${f}"
    exit 1
  fi
  s3_cp "${f}" "${s3_base}/$(basename "${f}")" \
    --content-type "$(file -b --mime-type "${f}" 2>/dev/null || echo application/octet-stream)"
  echo "Uploaded $(basename "${f}")"
done

export ENJOY_PLAYER_DL_BASE="${public_base}"
bash "${root}/.github/scripts/generate_update_feeds.sh" "${feed_args[@]}"

feed_dir="${FEED_OUT_DIR:-${root}/build/update-feeds}"
s3_cp "${feed_dir}/latest.json" "s3://${bucket}/${prefix}/latest.json" \
  --content-type application/json \
  --cache-control "max-age=300, must-revalidate"
s3_cp "${feed_dir}/appcast.xml" "s3://${bucket}/${prefix}/appcast.xml" \
  --content-type application/xml \
  --cache-control "max-age=300, must-revalidate"

purge_feed_cache

echo "Published ${version} to ${public_base}/${version}/"
