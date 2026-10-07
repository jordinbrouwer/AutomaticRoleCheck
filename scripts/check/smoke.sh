#!/usr/bin/env bash
set -euo pipefail

base_dir="$(dirname "$0")/.."
# shellcheck source=scripts/toc-lib.sh
source "$base_dir/toc-lib.sh"

icon_file="AutomaticRoleCheck.tga"

if [ ! -f "$icon_file" ]; then
  echo "[SMOKE CHECK] FAILED: Missing $icon_file."
  exit 1
fi

missing=0
toc_count=0

while IFS= read -r toc_file; do
  [ -n "$toc_file" ] || continue
  toc_count=$((toc_count + 1))

  if [ ! -f "$toc_file" ]; then
    echo "[SMOKE CHECK] FAILED: Missing $toc_file."
    exit 1
  fi

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    if [ ! -f "$file" ]; then
      echo "[SMOKE CHECK] FAILED: $toc_file references missing Lua file: $file"
      missing=1
    fi
  done < <(toc_lib_lua_files "$toc_file")
done < <(toc_lib_discover)

if [ "$toc_count" -eq 0 ]; then
  echo "[SMOKE CHECK] FAILED: No TOC files found."
  exit 1
fi

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "[SMOKE CHECK] PASSED: Required addon files and ${toc_count} TOC file(s) look valid."
