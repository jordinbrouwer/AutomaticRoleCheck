#!/usr/bin/env bash
set -euo pipefail

base_dir="$(dirname "$0")"
check_dir="$base_dir/check"

shopt -s nullglob
script_paths=("$check_dir"/*.sh)
if [ "${#script_paths[@]}" -eq 0 ]; then
  echo "[CHECK] FAILED: No check scripts found in '$check_dir'."
  exit 1
fi

script_modes=()
for path in "${script_paths[@]}"; do
  script_modes+=("$(basename "$path" .sh)")
done

run_script_mode() {
  local mode_name="$1"
  local script_path="$check_dir/$mode_name.sh"
  if [ ! -f "$script_path" ]; then
    echo "[CHECK] FAILED: Missing script for mode '$mode_name' ($script_path)."
    exit 1
  fi
  echo "[CHECK] Running mode '$mode_name' via '$script_path'."
  bash "$script_path"
}

print_help() {
  local discovered
  discovered="$(printf '%s\n' "${script_modes[@]}" | sort)"
  echo "Usage: bash ./scripts/check.sh [mode]"
  echo "Single-script modes:"
  while IFS= read -r mode_name; do
    printf '  - %s\n' "$mode_name"
  done <<< "$discovered"
  echo "Grouped modes:"
  echo "  - quick"
  echo "  - all"
}

mode="${1:-all}"
case "$mode" in
  -h|--help|help)
    print_help
    ;;
  quick)
    run_script_mode toc
    run_script_mode changelog
    run_script_mode readme
    run_script_mode commands
    ;;
  all)
    failed_modes=()
    while IFS= read -r mode_name; do
      if [ "$mode_name" = "worktree-clean" ]; then
        continue
      fi
      if ! run_script_mode "$mode_name"; then
        failed_modes+=("$mode_name")
      fi
    done < <(printf '%s\n' "${script_modes[@]}" | sort)
    if [ "${#failed_modes[@]}" -ne 0 ]; then
      printf -v joined '%s, ' "${failed_modes[@]}"
      echo "[CHECK] FAILED: One or more modes failed: ${joined%, }."
      exit 1
    fi
    ;;
  *)
    if printf '%s\n' "${script_modes[@]}" | grep -Fxq "$mode"; then
      run_script_mode "$mode"
    else
      echo "[CHECK] FAILED: Unknown mode '$mode'. Use --help for available modes."
      exit 1
    fi
    ;;
esac
