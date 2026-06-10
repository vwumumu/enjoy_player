#!/usr/bin/env bash
# Merge Sparkle appcast items by sparkle:os for multi-platform releases.
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: merge_appcast_xml.sh <new_appcast.xml> <remote_appcast.xml> <output.xml> <version>" >&2
  exit 2
fi

new="$1"
remote="$2"
out="$3"
version="$4"

pick_appcast_item() {
  local file="$1"
  local os_name="$2"
  local ver="$3"
  awk -v target_os="${os_name}" -v target_ver="${ver}" '
    BEGIN { in_item = 0; block = "" }
    /<item>/ {
      in_item = 1
      block = $0 ORS
      next
    }
    in_item {
      block = block $0 ORS
      if ($0 ~ /<\/item>/) {
        if (block ~ ("sparkle:os=\"" target_os "\"") &&
            block ~ ("<sparkle:shortVersionString>" target_ver "</sparkle:shortVersionString>")) {
          printf "%s", block
          exit 0
        }
        in_item = 0
        block = ""
      }
    }
  ' "${file}"
}

pick_merged_item() {
  local os_name="$1"
  local item=""
  item="$(pick_appcast_item "${new}" "${os_name}" "${version}" || true)"
  if [[ -z "${item}" && -f "${remote}" ]]; then
    item="$(pick_appcast_item "${remote}" "${os_name}" "${version}" || true)"
  fi
  printf '%s' "${item}"
}

if ! grep -q '<channel>' "${new}"; then
  echo "Invalid appcast: missing channel in ${new}" >&2
  exit 1
fi

header="$(sed -n '1,/<language>en<\/language>/p' "${new}")"
footer=$'  </channel>\n</rss>'
mac_item="$(pick_merged_item macos)"
win_item="$(pick_merged_item windows)"

{
  printf '%s\n' "${header}"
  [[ -n "${mac_item}" ]] && printf '%s' "${mac_item}"
  [[ -n "${win_item}" ]] && printf '%s' "${win_item}"
  printf '%s\n' "${footer}"
} > "${out}"
