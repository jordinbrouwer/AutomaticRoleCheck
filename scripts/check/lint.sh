#!/usr/bin/env bash
set -euo pipefail

if ! command -v luacheck >/dev/null 2>&1; then
  echo "[LINT CHECK] FAILED: luacheck is required."
  exit 1
fi

lua_files="$(
  find . -maxdepth 1 -name '*.lua' -printf '%f\n' | sort
)"

if [ -z "$lua_files" ]; then
  echo "[LINT CHECK] FAILED: No Lua files found in repository."
  exit 1
fi

echo "$lua_files" | xargs luacheck
echo "[LINT CHECK] PASSED: Luacheck completed successfully."
