#!/usr/bin/env bash
set -euo pipefail

if [ "${RELEASE_DEBUG:-0}" = "1" ]; then
  set -x
fi

output_file="${1:-}"
github_ref="${2:-}"
github_ref_name="${3:-}"
notes_path="${RELEASE_NOTES_PATH:-.tmp/release-notes.md}"

if [ -z "$output_file" ]; then
  echo "[RELEASE] FAILED: Missing output file argument."
  exit 1
fi

: > "$output_file"

if ! command -v git >/dev/null 2>&1; then
  echo "[RELEASE] FAILED: Git is required."
  exit 1
fi
if ! command -v zip >/dev/null 2>&1; then
  echo "[RELEASE] FAILED: zip is required."
  exit 1
fi
if ! command -v unzip >/dev/null 2>&1; then
  echo "[RELEASE] FAILED: unzip is required."
  exit 1
fi
if [ ! -f "CHANGELOG.md" ]; then
  echo "[RELEASE] FAILED: CHANGELOG.md not found."
  exit 1
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[RELEASE] FAILED: Run this script inside repository."
  exit 1
fi

mkdir -p "$(dirname "$notes_path")"

if ! grep -Eq '^## \[Unreleased\]' CHANGELOG.md; then
  echo "[RELEASE] FAILED: CHANGELOG.md must contain an Unreleased header."
  exit 1
fi

release_date="$(
  sed -nE 's/^## \[[0-9]+\.[0-9]+\.[0-9]+ \(([0-9]{4}-[0-9]{2}-[0-9]{2})\)\].*/\1/p' CHANGELOG.md | head -n 1
)"
if [ -z "$release_date" ]; then
  echo "[RELEASE] FAILED: First release heading must include a date (YYYY-MM-DD)."
  exit 1
fi
today="$(date +%Y-%m-%d)"
if [ "$release_date" \> "$today" ]; then
  echo "[RELEASE] FAILED: First release date '$release_date' is in the future."
  exit 1
fi

version="$(
  sed -nE 's/^## \[([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' CHANGELOG.md | head -n 1
)"
if [ -z "$version" ]; then
  echo "[RELEASE] FAILED: Could not extract latest version from CHANGELOG.md."
  exit 1
fi

awk '
  BEGIN { in_section = 0; first_done = 0 }
  /^## \[[0-9]+\.[0-9]+\.[0-9]+/ {
    if (first_done) exit
    in_section = 1
    first_done = 1
    next
  }
  in_section { print }
' CHANGELOG.md > "$notes_path"

awk '
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
' "$notes_path" > "$notes_path.tmp"
mv "$notes_path.tmp" "$notes_path"

if [ ! -s "$notes_path" ]; then
  echo "[RELEASE] FAILED: Latest release notes section is empty."
  exit 1
fi

if [ "${github_ref#refs/tags/}" != "$github_ref" ]; then
  tag_version="$github_ref_name"
  if ! printf '%s\n' "$tag_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "[RELEASE] FAILED: Tag '$github_ref_name' is not supported (expected 1.2.3)."
    exit 1
  fi
  if [ "$tag_version" != "$version" ]; then
    echo "[RELEASE] FAILED: Tag version '$tag_version' does not match changelog version '$version'."
    exit 1
  fi
fi

addon_name="$(basename "$(pwd)")"
output_dir=".tmp"
is_tag_build=0
if [ "${github_ref#refs/tags/}" != "$github_ref" ]; then
  is_tag_build=1
fi

archive_suffix="${RELEASE_ARCHIVE_SUFFIX:-}"
if [ -z "$archive_suffix" ] && [ "$is_tag_build" -eq 0 ] && [ "${CI:-}" != "true" ]; then
  archive_suffix="$(date +%Y%m%d-%H%M%S)-$(git rev-parse --short HEAD)"
fi

archive_version="$version"
if [ -n "$archive_suffix" ]; then
  archive_version="${version}-${archive_suffix}"
fi

archive_path="$output_dir/${addon_name}-${archive_version}.zip"
tmp_dir="$(mktemp -d)"

mkdir -p "$output_dir"
trap 'rm -rf "$tmp_dir"' EXIT INT TERM
git archive --format=tar --prefix="${addon_name}/" HEAD | tar -xf - -C "$tmp_dir"

toc_path="$tmp_dir/$addon_name/AutomaticRoleCheck.toc"
if [ ! -f "$toc_path" ]; then
  echo "[RELEASE] FAILED: Missing AutomaticRoleCheck.toc in archive source."
  exit 1
fi

if ! awk -v v="$version" '
  BEGIN { updated = 0 }
  /^## Version: / { print "## Version: " v; updated = 1; next }
  { print }
  END { if (updated == 0) exit 2 }
' "$toc_path" > "$toc_path.tmp"; then
  echo "[RELEASE] FAILED: Could not update TOC version line."
  rm -f "$toc_path.tmp"
  exit 1
fi
mv "$toc_path.tmp" "$toc_path"

rm -f "$archive_path"
(cd "$tmp_dir" && zip -qr "$OLDPWD/$archive_path" "$addon_name")

archive_files="$(unzip -Z1 "$archive_path")"
required_archive_files="
$addon_name/AutomaticRoleCheck.toc
$addon_name/AutomaticRoleCheck.tga
"
for file in $required_archive_files; do
  if ! printf '%s\n' "$archive_files" | grep -Fxq "$file"; then
    echo "[RELEASE] FAILED: Archive missing required file '$file'."
    exit 1
  fi
done

toc_lua_files="$(awk '/^[A-Za-z0-9_].*\.lua$/{print $0}' "$toc_path")"
for lua_file in $toc_lua_files; do
  archive_lua_path="$addon_name/$lua_file"
  if ! printf '%s\n' "$archive_files" | grep -Fxq "$archive_lua_path"; then
    echo "[RELEASE] FAILED: Archive missing TOC Lua file '$archive_lua_path'."
    exit 1
  fi
done

for disallowed in ".github/" "scripts/" ".luacheckrc"; do
  if printf '%s\n' "$archive_files" | grep -Fq "$addon_name/$disallowed"; then
    echo "[RELEASE] FAILED: Archive includes dev-only path '$addon_name/$disallowed'."
    exit 1
  fi
done

echo "version=$version" >> "$output_file"
echo "archive_version=$archive_version" >> "$output_file"
echo "archive_path=$archive_path" >> "$output_file"
echo "notes_path=$notes_path" >> "$output_file"

echo "[RELEASE] PASSED: Created '$archive_path' with version '$archive_version'."
