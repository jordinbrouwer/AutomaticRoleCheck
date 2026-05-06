#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "README.md" ]; then
  echo "[README CHECK] FAILED: README.md not found."
  exit 1
fi

command_file="AutomaticRoleCheck_Command.lua"
if [ ! -f "$command_file" ]; then
  echo "[README CHECK] FAILED: $command_file not found."
  exit 1
fi

handler_keys="$(
  sed -n '/^commandDefinitions = {/,/^}/p' "$command_file" | \
    sed -nE 's/^  ([a-z0-9_]+)[[:space:]]*= \{/\1/p' | sort -u
)"
if [ -z "$handler_keys" ]; then
  echo "[README CHECK] FAILED: Could not parse command definitions from $command_file."
  exit 1
fi

missing=0

if ! grep -Fq "/arc" README.md; then
  echo "[README CHECK] FAILED: Missing expected README token: /arc"
  missing=1
fi

for key in $handler_keys; do
  token="/arc $key"
  if ! grep -Fq "$token" README.md; then
    echo "[README CHECK] FAILED: Missing expected README token: $token"
    missing=1
  fi
done

minimap_block="$(
  awk '
    /minimap = {/ { in_block = 1 }
    in_block { print }
    in_block && /^  },$/ { exit }
  ' "$command_file"
)"
minimap_args="$(
  printf '%s\n' "$minimap_block" | sed -nE 's/^[[:space:]]*args = "(\[[^"]+\])".*/\1/p'
)"
if [ -z "$minimap_args" ]; then
  echo "[README CHECK] FAILED: Could not parse minimap command args."
  exit 1
fi
minimap_usage="/arc minimap $minimap_args"
if ! grep -Fq "$minimap_usage" README.md; then
  echo "[README CHECK] FAILED: Missing expected README token: $minimap_usage"
  missing=1
fi

for click_hint in "Left-click" "Right-click"; do
  if ! grep -Fq "$click_hint" README.md; then
    echo "[README CHECK] FAILED: Missing expected README token: $click_hint"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

slash_section="$(
  awk '
    /^### Slash commands$/ { in_section = 1; next }
    /^### / && in_section { exit }
    in_section { print }
  ' README.md
)"
if [ -z "$slash_section" ]; then
  echo "[README CHECK] FAILED: Could not read the 'Slash commands' section."
  exit 1
fi

for key in $handler_keys; do
  required_in_section="/arc $key"
  if ! printf '%s\n' "$slash_section" | grep -Fq "$required_in_section"; then
    echo "[README CHECK] FAILED: Missing '$required_in_section' in the 'Slash commands' section."
    exit 1
  fi
done

echo "[README CHECK] PASSED: README command and minimap usage coverage looks good."
