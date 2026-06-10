#!/usr/bin/env bash
# Emit appcast.xml + latest.json for dl.enjoy.bot from versioned release artifacts.
set -euo pipefail

lib="$(dirname "$0")/release_lib.sh"
# shellcheck source=release_lib.sh
source "${lib}"

root="$(release_repo_root)"
cd "${root}"

release_parse_artifact_args "$@"

version="${VERSION:-$(release_version)}"
build="${BUILD_NUMBER:-$(release_build_number)}"
base_url="${ENJOY_PLAYER_DL_BASE:-https://dl.enjoy.bot/player}"
min_supported="${MIN_SUPPORTED_VERSION:-${version}}"
notes="${RELEASE_NOTES:-}"

json_string() {
  local s="${1//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '"%s"' "${s}"
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

declare -A assets=()

add_asset() {
  local key="$1"
  local file="$2"
  if [[ ! -f "${file}" ]]; then
    echo "skip missing asset (${key}): ${file}" >&2
    return 0
  fi
  local name sha url
  name="$(basename "${file}")"
  sha="$(sha256_file "${file}")"
  url="${base_url}/${version}/${name}"
  assets["${key}"]="${name}|${url}|${sha}|${file}"
}

key=""
for key in "${RELEASE_ARTIFACT_KEYS[@]}"; do
  add_asset "${key}" "${RELEASE_ARTIFACT_PATHS[$key]}"
done

out_dir="${FEED_OUT_DIR:-${root}/build/update-feeds}"
mkdir -p "${out_dir}"

latest_json="${out_dir}/latest.json"
{
  echo '{'
  echo "  \"version\": \"${version}\","
  echo "  \"build\": ${build},"
  echo "  \"minSupportedVersion\": \"${min_supported}\","
  echo "  \"notes\": $(json_string "${notes}"),"
  echo '  "assets": {'
  first=true
  for key in "${!assets[@]}"; do
    IFS='|' read -r _file url sha _path <<< "${assets[$key]}"
    if [[ "${first}" == true ]]; then first=false; else echo ','; fi
    printf '    "%s": {"url": "%s", "sha256": "%s", "file": "%s"}' \
      "${key}" "${url}" "${sha}" "${_file}"
  done
  echo
  echo '  }'
  echo '}'
} > "${latest_json}"

if [[ -n "${MERGE_LATEST_JSON:-}" && -f "${MERGE_LATEST_JSON}" ]]; then
  merged_json="${out_dir}/latest.merged.json"
  bash "${root}/.github/scripts/merge_latest_json.sh" \
    "${latest_json}" "${MERGE_LATEST_JSON}" "${merged_json}"
  mv -f "${merged_json}" "${latest_json}"
  echo "Merged remote latest.json assets for version ${version}."
fi

appcast="${out_dir}/appcast.xml"
sparkle_mac_sig="${SPARKLE_ED_SIGNATURE_MACOS:-}"
sparkle_win_sig="${SPARKLE_ED_SIGNATURE_WINDOWS:-}"
pub_date="$(date -u +"%a, %d %b %Y %H:%M:%S +0000")"

{
  echo '<?xml version="1.0" encoding="utf-8"?>'
  echo '<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">'
  echo '  <channel>'
  echo '    <title>Enjoy Player</title>'
  echo '    <link>https://enjoy.bot</link>'
  echo '    <description>Enjoy Player direct-download updates</description>'
  echo '    <language>en</language>'

  if [[ -n "${assets[macos]:-}" ]]; then
    IFS='|' read -r _name url _sha mac_path <<< "${assets[macos]}"
    mac_len=0
    if [[ -f "${mac_path}" ]]; then
      mac_len="$(wc -c < "${mac_path}" | tr -d ' ')"
    fi
    echo '    <item>'
    echo "      <title>Version ${version}</title>"
    echo "      <pubDate>${pub_date}</pubDate>"
    echo '      <sparkle:version>'"${build}"'</sparkle:version>'
    echo '      <sparkle:shortVersionString>'"${version}"'</sparkle:shortVersionString>'
    echo '      <enclosure url="'"${url}"'" sparkle:os="macos" type="application/octet-stream" length="'"${mac_len}"'"'
    if [[ -n "${sparkle_mac_sig}" ]]; then
      echo '        sparkle:edSignature="'"${sparkle_mac_sig}"'"'
    fi
    echo '      />'
    echo '    </item>'
  fi

  if [[ -n "${assets[windows]:-}" ]]; then
    IFS='|' read -r _name url _sha win_path <<< "${assets[windows]}"
    win_len=0
    if [[ -f "${win_path}" ]]; then
      win_len="$(wc -c < "${win_path}" | tr -d ' ')"
    fi
    echo '    <item>'
    echo "      <title>Version ${version}</title>"
    echo "      <pubDate>${pub_date}</pubDate>"
    echo '      <sparkle:version>'"${build}"'</sparkle:version>'
    echo '      <sparkle:shortVersionString>'"${version}"'</sparkle:shortVersionString>'
    echo '      <enclosure url="'"${url}"'" sparkle:os="windows" type="application/octet-stream" length="'"${win_len}"'"'
    if [[ -n "${sparkle_win_sig}" ]]; then
      echo '        sparkle:dsaSignature="'"${sparkle_win_sig}"'"'
    fi
    echo '      />'
    echo '    </item>'
  fi

  echo '  </channel>'
  echo '</rss>'
} > "${appcast}"

if [[ -n "${MERGE_APPCAST_XML:-}" && -f "${MERGE_APPCAST_XML}" ]]; then
  merged_appcast="${out_dir}/appcast.merged.xml"
  bash "${root}/.github/scripts/merge_appcast_xml.sh" \
    "${appcast}" "${MERGE_APPCAST_XML}" "${merged_appcast}" "${version}"
  mv -f "${merged_appcast}" "${appcast}"
  echo "Merged remote appcast.xml items for version ${version}."
fi

echo "Wrote ${latest_json}"
echo "Wrote ${appcast}"
