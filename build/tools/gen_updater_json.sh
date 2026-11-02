#!/usr/bin/env bash
set -eu

out="${1:?}"
device="${2:?}"
prop="$out/system/build.prop"
json="$out/$device.json"

prop_get() { sed -n "s/^$1=//p" "$prop" | head -n1; }

zip="$(ls -t "$out"/MirageOS*.zip 2>/dev/null | head -n1)"
if [ -z "$zip" ]; then
    zip="$(ls -t "$out"/*-ota-*.zip 2>/dev/null | head -n1)"
fi
[ -f "$zip" ] || { echo "no ota zip in $out" >&2; exit 1; }

name="$(basename "$zip")"
size="$(stat -c %s "$zip")"
sum="$(sha256sum "$zip" | cut -d' ' -f1)"
stamp="$(prop_get ro.build.date.utc)"
[ -n "$stamp" ] || stamp="$(stat -c %Y "$zip")"
sdk="$(prop_get ro.build.version.sdk)"
version="$(prop_get ro.mirage.version)"
[ -n "$version" ] || version="$(prop_get ro.modversion)"
[ -n "$version" ] || version="$(prop_get ro.build.version.release)"
type="${MIRAGE_OTA_TYPE:-ci}"
url=""
if [ -n "${MIRAGE_OTA_URL:-}" ]; then
    url="${MIRAGE_OTA_URL%/}/$name"
fi

cat > "$json" << JSON
[
    {
        "datetime": $stamp,
        "files": [
            {
                "filename": "$name",
                "os_sdk_level": $sdk,
                "sha256": "$sum",
                "size": $size,
                "url": "$url"
            }
        ],
        "type": "$type",
        "version": "$version"
    }
]
JSON

if [ -z "${NO_COLOR:-}" ]; then
    hi=$'\033[38;5;215m'; dim=$'\033[38;5;245m'; bold=$'\033[1m'; off=$'\033[0m'
else
    hi=""; dim=""; bold=""; off=""
fi
human="$(numfmt --to=iec --suffix=B "$size" 2>/dev/null || echo "${size}B")"

printf '\n'
printf '  %s%sMirageOS%s %s· %s · build finished%s\n' "$bold" "$hi" "$off" "$dim" "$device" "$off"
printf '  %s─────────────────────────────────────────%s\n\n' "$dim" "$off"
printf '  %sThank you for building MirageOS.%s\n' "$bold" "$off"
printf '  Somewhere, a phone is about to get a second life.\n\n'
printf '  %spackage%s  %s\n' "$dim" "$off" "$name"
printf '  %ssize%s     %s\n' "$dim" "$off" "$human"
printf '  %ssha256%s   %s…\n' "$dim" "$off" "${sum:0:16}"
printf '  %sjson%s     %s\n\n' "$dim" "$off" "$json"
