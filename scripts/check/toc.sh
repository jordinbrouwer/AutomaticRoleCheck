#!/usr/bin/env bash
set -euo pipefail

toc_files="$(
  awk '/^[A-Za-z0-9_].*\.lua$/{print $0}' AutomaticRoleCheck.toc | sort
)"

repo_files="$(
  find . -maxdepth 1 -name '*.lua' -printf '%f\n' | sort
)"

if [ "$toc_files" != "$repo_files" ]; then
  echo "[TOC CHECK] FAILED: TOC and repository Lua file lists differ."
  echo "[TOC CHECK] TOC entries:"
  echo "$toc_files"
  echo "[TOC CHECK] Repository root Lua files:"
  echo "$repo_files"
  exit 1
fi

version_line_count="$(grep -Ec '^## Version: ' AutomaticRoleCheck.toc || true)"
if [ "$version_line_count" -ne 1 ]; then
  echo "[TOC CHECK] FAILED: Expected exactly one '## Version:' line in AutomaticRoleCheck.toc, found $version_line_count."
  exit 1
fi

echo "[TOC CHECK] PASSED: TOC Lua file list and version line look valid."
