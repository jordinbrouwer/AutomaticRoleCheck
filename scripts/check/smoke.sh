#!/usr/bin/env bash
set -euo pipefail

toc_file="AutomaticRoleCheck.toc"
icon_file="AutomaticRoleCheck.tga"

if [ ! -f "$toc_file" ]; then
  echo "[SMOKE CHECK] FAILED: Missing $toc_file."
  exit 1
fi

if [ ! -f "$icon_file" ]; then
  echo "[SMOKE CHECK] FAILED: Missing $icon_file."
  exit 1
fi

missing=0
toc_lua_files="$(awk '/^[A-Za-z0-9_].*\.lua$/{print $0}' "$toc_file")"
for file in $toc_lua_files; do
  if [ ! -f "$file" ]; then
    echo "[SMOKE CHECK] FAILED: TOC references missing Lua file: $file"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "[SMOKE CHECK] PASSED: Required addon files and TOC Lua references are valid."
