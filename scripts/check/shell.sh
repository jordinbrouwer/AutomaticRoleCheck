#!/usr/bin/env bash
set -euo pipefail

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "[SHELL CHECK] FAILED: shellcheck is required."
  exit 1
fi

shellcheck scripts/*.sh scripts/check/*.sh
echo "[SHELL CHECK] PASSED: ShellCheck completed successfully."

