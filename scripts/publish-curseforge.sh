#!/usr/bin/env bash
set -euo pipefail

base_dir="$(dirname "$0")"
# shellcheck source=scripts/toc-lib.sh
source "$base_dir/toc-lib.sh"

if [ "${PUBLISH_DEBUG:-0}" = "1" ]; then
  set -x
fi

archive_path="${1:-}"
notes_path="${2:-}"
version="${3:-}"
project_id="${CF_PROJECT_ID:-448353}"
api_base="https://wow.curseforge.com/api"

if [ -z "$archive_path" ] || [ -z "$notes_path" ] || [ -z "$version" ]; then
  echo "[PUBLISH] FAILED: Usage: publish-curseforge.sh <archive_path> <notes_path> <version>"
  exit 1
fi

if [ -z "${CF_API_TOKEN:-}" ]; then
  echo "[PUBLISH] FAILED: CF_API_TOKEN is required."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "[PUBLISH] FAILED: curl is required."
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "[PUBLISH] FAILED: python3 is required."
  exit 1
fi

if [ ! -f "$archive_path" ]; then
  echo "[PUBLISH] FAILED: Archive not found: $archive_path"
  exit 1
fi

if [ ! -f "$notes_path" ]; then
  echo "[PUBLISH] FAILED: Release notes not found: $notes_path"
  exit 1
fi

interfaces_csv="$(toc_lib_all_interfaces_csv ".")"
if [ -z "$interfaces_csv" ]; then
  echo "[PUBLISH] FAILED: No interface versions found in TOC files."
  exit 1
fi

toc_count="$(toc_lib_discover | wc -l | tr -d ' ')"
echo "[PUBLISH] Using interface versions from ${toc_count} TOC file(s): ${interfaces_csv}"

versions_json="$(
  curl -sS \
    -H "X-Api-Token: ${CF_API_TOKEN}" \
    "${api_base}/game/versions"
)"

game_version_ids="$(
  INTERFACES_CSV="$interfaces_csv" \
  VERSIONS_JSON="$versions_json" \
  python3 - <<'PY'
import json
import os
import sys

interfaces = [i for i in os.environ["INTERFACES_CSV"].split(",") if i]
versions = json.loads(os.environ["VERSIONS_JSON"])
by_api = {
    str(v.get("apiVersion")): v["id"]
    for v in versions
    if v.get("apiVersion") is not None
}

missing = [i for i in interfaces if i not in by_api]
if missing:
    print(
        "[PUBLISH] FAILED: No CurseForge game versions for Interface values: "
        + ", ".join(missing),
        file=sys.stderr,
    )
    sys.exit(1)

ids = [by_api[i] for i in interfaces]
print(",".join(str(i) for i in ids))
PY
)"

metadata="$(
  NOTES_PATH="$notes_path" \
  VERSION="$version" \
  GAME_VERSION_IDS="$game_version_ids" \
  python3 - <<'PY'
import json
import os

with open(os.environ["NOTES_PATH"], encoding="utf-8") as f:
    changelog = f.read()

game_versions = [int(x) for x in os.environ["GAME_VERSION_IDS"].split(",") if x]
print(
    json.dumps(
        {
            "changelog": changelog,
            "changelogType": "markdown",
            "displayName": os.environ["VERSION"],
            "gameVersions": game_versions,
            "releaseType": "release",
        }
    )
)
PY
)"

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT INT TERM

http_code="$(
  curl -sS \
    -o "$response_file" \
    -w "%{http_code}" \
    -H "X-Api-Token: ${CF_API_TOKEN}" \
    -F "metadata=${metadata}" \
    -F "file=@${archive_path}" \
    "${api_base}/projects/${project_id}/upload-file"
)"

if [ "$http_code" != "200" ]; then
  echo "[PUBLISH] FAILED: CurseForge upload returned HTTP $http_code"
  cat "$response_file"
  echo
  exit 1
fi

file_id="$(
  RESPONSE_FILE="$response_file" python3 - <<'PY'
import json
import os
import sys

with open(os.environ["RESPONSE_FILE"], encoding="utf-8") as f:
    data = json.load(f)
file_id = data.get("id")
if file_id is None:
    print("[PUBLISH] FAILED: Upload response missing file id.", file=sys.stderr)
    sys.exit(1)
print(file_id)
PY
)"

echo "[PUBLISH] PASSED: Uploaded '$archive_path' as CurseForge file id $file_id (version $version)."
