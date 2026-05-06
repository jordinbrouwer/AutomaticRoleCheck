#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "CHANGELOG.md" ]; then
  echo "[CHANGELOG CHECK] FAILED: CHANGELOG.md not found."
  exit 1
fi

if ! grep -Eq '^## \[Unreleased\]' CHANGELOG.md; then
  echo "[CHANGELOG CHECK] FAILED: Missing Unreleased header."
  exit 1
fi

invalid_headers="$(
  awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+/ { print }' CHANGELOG.md | \
    grep -Ev '^## \[[0-9]+\.[0-9]+\.[0-9]+ \([0-9]{4}-[0-9]{2}-[0-9]{2}\)\]' || true
)"
if [ -n "$invalid_headers" ]; then
  echo "[CHANGELOG CHECK] FAILED: Invalid release heading format detected."
  echo "$invalid_headers"
  exit 1
fi

version="$(
  sed -nE 's/^## \[([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' CHANGELOG.md | head -n 1
)"
if [ -z "$version" ]; then
  echo "[CHANGELOG CHECK] FAILED: Missing first semantic version header."
  exit 1
fi

release_date="$(
  sed -nE 's/^## \[[0-9]+\.[0-9]+\.[0-9]+ \(([0-9]{4}-[0-9]{2}-[0-9]{2})\)\].*/\1/p' CHANGELOG.md | head -n 1
)"
if [ -z "$release_date" ]; then
  echo "[CHANGELOG CHECK] FAILED: Missing release date in first version heading."
  exit 1
fi
today="$(date +%Y-%m-%d)"
if [ "$release_date" \> "$today" ]; then
  echo "[CHANGELOG CHECK] FAILED: First release date '$release_date' is in the future."
  exit 1
fi

notes="$(
  awk '
    BEGIN { in_section = 0; first_done = 0 }
    /^## \[[0-9]+\.[0-9]+\.[0-9]+/ {
      if (first_done) exit
      in_section = 1
      first_done = 1
      next
    }
    in_section { print }
  ' CHANGELOG.md | awk '
    BEGIN { start = 0; n = 0 }
    {
      lines[++n] = $0
      if (!start && $0 !~ /^[[:space:]]*$/) start = n
    }
    END {
      if (!start) exit 1
      last = n
      while (last >= start && lines[last] ~ /^[[:space:]]*$/) last--
      for (i = start; i <= last; i++) print lines[i]
    }
  '
)"

if [ -z "$notes" ]; then
  echo "[CHANGELOG CHECK] FAILED: First version section is empty."
  exit 1
fi

echo "[CHANGELOG CHECK] PASSED: Found version '$version' with date '$release_date' and non-empty release notes."
