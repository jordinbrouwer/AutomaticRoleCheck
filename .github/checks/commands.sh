#!/usr/bin/env bash
set -euo pipefail
: "${LOG_PREFIX:=commands}"

command_file="src/AutomaticRoleCheck_Command.lua"

if [ ! -f "$command_file" ]; then
  echo "[$LOG_PREFIX] FAILED: $command_file not found."
  exit 1
fi

missing=0
for token in 'SLASH_AUTOMATICROLECHECK1 = "/arc"' 'SlashCmdList.AUTOMATICROLECHECK = function'; do
  if ! grep -Fq "$token" "$command_file"; then
    echo "[$LOG_PREFIX] FAILED: Missing required token '$token'."
    missing=1
  fi
done

handler_keys="$(
  sed -n '/^commandDefinitions = {/,/^}/p' "$command_file" | \
    sed -nE 's/^  ([a-z0-9_]+)[[:space:]]*= \{/\1/p' | sort -u
)"
if [ -z "$handler_keys" ]; then
  echo "[$LOG_PREFIX] FAILED: Could not parse commandDefinitions keys."
  exit 1
fi

if ! grep -Fq "local function HandleHelp()" "$command_file"; then
  echo "[$LOG_PREFIX] FAILED: Missing HandleHelp function."
  missing=1
fi

if ! grep -Fq "for _, key in ipairs(orderedKeys) do" "$command_file"; then
  echo "[$LOG_PREFIX] FAILED: HandleHelp should iterate ordered command keys."
  missing=1
fi

if ! grep -Fq "local definition = commandDefinitions[key]" "$command_file"; then
  echo "[$LOG_PREFIX] FAILED: HandleHelp should derive text from commandDefinitions."
  missing=1
fi

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "[$LOG_PREFIX] PASSED: Command registration and help contract look valid."
