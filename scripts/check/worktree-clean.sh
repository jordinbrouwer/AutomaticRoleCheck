#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[WORKTREE CHECK] FAILED: Run this script inside a git repository."
  exit 1
fi

if ! git diff --quiet --exit-code; then
  echo "[WORKTREE CHECK] FAILED: Tracked working tree has unexpected changes."
  exit 1
fi

if ! git diff --cached --quiet --exit-code; then
  echo "[WORKTREE CHECK] FAILED: Index has staged tracked changes."
  exit 1
fi

echo "[WORKTREE CHECK] PASSED: Tracked working tree and index are clean."
