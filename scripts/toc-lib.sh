#!/usr/bin/env bash
# Shared helpers for discovering and reading addon TOC files.

toc_lib_addon_basename() {
  printf '%s' "AutomaticRoleCheck"
}

toc_lib_discover() {
  local search_dir="${1:-.}"
  local base
  base="$(toc_lib_addon_basename)"
  local primary="${base}.toc"
  local primary_path="$search_dir/$primary"

  if [ ! -f "$primary_path" ]; then
    echo "[TOC LIB] FAILED: Missing primary TOC '$primary_path'." >&2
    return 1
  fi

  printf '%s\n' "$primary"
  find "$search_dir" -maxdepth 1 -name "${base}_*.toc" -printf '%f\n' | sort
}

toc_lib_interface_csv() {
  local toc_path="$1"
  local search_dir="${2:-.}"
  local interface_line

  if [ ! -f "$toc_path" ] && [ -f "$search_dir/$toc_path" ]; then
    toc_path="$search_dir/$toc_path"
  fi

  interface_line="$(
    sed -nE 's/^## Interface:[[:space:]]*(.*)$/\1/p' "$toc_path" | head -n 1
  )"
  if [ -z "$interface_line" ]; then
    echo "[TOC LIB] FAILED: Could not read ## Interface: from '$toc_path'." >&2
    return 1
  fi

  printf '%s' "$interface_line" | tr -d '[:space:]'
}

toc_lib_lua_files() {
  local toc_path="$1"
  local search_dir="${2:-.}"

  if [ ! -f "$toc_path" ] && [ -f "$search_dir/$toc_path" ]; then
    toc_path="$search_dir/$toc_path"
  fi

  awk '/^[A-Za-z0-9_].*\.lua$/{print $0}' "$toc_path" | sort
}

toc_lib_all_interfaces_csv() {
  local toc_path
  local interfaces=()
  local csv part

  local search_dir="${1:-.}"

  while IFS= read -r toc_path; do
    [ -n "$toc_path" ] || continue
    csv="$(toc_lib_interface_csv "$toc_path" "$search_dir")"
    IFS=',' read -ra parts <<< "$csv"
    for part in "${parts[@]}"; do
      [ -n "$part" ] || continue
      interfaces+=("$part")
    done
  done < <(toc_lib_discover "$search_dir")

  python3 - <<'PY' "${interfaces[@]}"
import sys

seen = set()
ordered = []
for value in sys.argv[1:]:
    if value not in seen:
        seen.add(value)
        ordered.append(value)

print(",".join(ordered))
PY
}

toc_lib_update_version() {
  local toc_path="$1"
  local version="$2"

  if ! awk -v v="$version" '
    BEGIN { updated = 0 }
    /^## Version: / { print "## Version: " v; updated = 1; next }
    { print }
    END { if (updated == 0) exit 2 }
  ' "$toc_path" > "$toc_path.tmp"; then
    echo "[TOC LIB] FAILED: Could not update ## Version: in '$toc_path'." >&2
    rm -f "$toc_path.tmp"
    return 1
  fi

  mv "$toc_path.tmp" "$toc_path"
}
