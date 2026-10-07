#!/usr/bin/env bash
set -euo pipefail

base_dir="$(dirname "$0")/.."
# shellcheck source=scripts/toc-lib.sh
source "$base_dir/toc-lib.sh"

repo_files="$(
  find . -maxdepth 1 -name '*.lua' -printf '%f\n' | sort
)"

reference_lua_files=""
toc_count=0

while IFS= read -r toc_file; do
  [ -n "$toc_file" ] || continue
  toc_count=$((toc_count + 1))

  if ! git ls-files --error-unmatch "$toc_file" >/dev/null 2>&1; then
    echo "[TOC CHECK] FAILED: $toc_file exists but is not tracked by git."
    exit 1
  fi

  version_line_count="$(grep -Ec '^## Version: ' "$toc_file" || true)"
  if [ "$version_line_count" -ne 1 ]; then
    echo "[TOC CHECK] FAILED: Expected exactly one '## Version:' line in $toc_file, found $version_line_count."
    exit 1
  fi

  if ! toc_lib_interface_csv "$toc_file" >/dev/null; then
    exit 1
  fi

  toc_lua_files="$(toc_lib_lua_files "$toc_file")"
  if [ -z "$reference_lua_files" ]; then
    reference_lua_files="$toc_lua_files"
  elif [ "$toc_lua_files" != "$reference_lua_files" ]; then
    echo "[TOC CHECK] FAILED: Lua file lists differ between TOC files."
    echo "[TOC CHECK] Expected all TOCs to list the same Lua files."
    echo "[TOC CHECK] Reference from $(toc_lib_discover | head -n 1):"
    echo "$reference_lua_files"
    echo "[TOC CHECK] Mismatch in $toc_file:"
    echo "$toc_lua_files"
    exit 1
  fi
done < <(toc_lib_discover)

if [ "$toc_count" -eq 0 ]; then
  echo "[TOC CHECK] FAILED: No TOC files found."
  exit 1
fi

if [ "$reference_lua_files" != "$repo_files" ]; then
  echo "[TOC CHECK] FAILED: TOC and repository Lua file lists differ."
  echo "[TOC CHECK] TOC entries:"
  echo "$reference_lua_files"
  echo "[TOC CHECK] Repository root Lua files:"
  echo "$repo_files"
  exit 1
fi

echo "[TOC CHECK] PASSED: ${toc_count} TOC file(s), Lua file list, and version lines look valid."
