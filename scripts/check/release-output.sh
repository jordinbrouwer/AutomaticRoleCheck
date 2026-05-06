#!/usr/bin/env bash
set -euo pipefail

output_file="$(mktemp)"
trap 'rm -f "$output_file"' EXIT INT TERM

github_ref="${GITHUB_REF:-refs/heads/local}"
github_ref_name="${GITHUB_REF_NAME:-local}"

mkdir -p .tmp
rm -f .tmp/*.zip

bash ./scripts/release.sh "$output_file" "$github_ref" "$github_ref_name"

required_keys="
version
archive_version
archive_path
notes_path
"
for key in $required_keys; do
  if ! grep -Eq "^${key}=.+" "$output_file"; then
    echo "[RELEASE OUTPUT CHECK] FAILED: Missing required output key '$key'."
    exit 1
  fi
done

notes_path="$(sed -nE 's/^notes_path=(.+)$/\1/p' "$output_file" | head -n 1)"
if [ -z "$notes_path" ] || [ ! -s "$notes_path" ]; then
  echo "[RELEASE OUTPUT CHECK] FAILED: notes_path output is missing or empty."
  exit 1
fi

archive_path="$(sed -nE 's/^archive_path=(.+)$/\1/p' "$output_file" | head -n 1)"
if [ -z "$archive_path" ] || [ ! -s "$archive_path" ]; then
  echo "[RELEASE OUTPUT CHECK] FAILED: archive_path output is missing or archive does not exist."
  exit 1
fi

zip_count="$(find .tmp -maxdepth 1 -name '*.zip' -printf '%f\n' | wc -l | tr -d ' ')"
if [ "$zip_count" -ne 1 ]; then
  echo "[RELEASE OUTPUT CHECK] FAILED: Expected exactly 1 zip in .tmp, found $zip_count."
  exit 1
fi

echo "[RELEASE OUTPUT CHECK] PASSED: release.sh output contract is valid."
