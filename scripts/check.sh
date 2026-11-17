#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

check_dir="scripts/check"

# Modes run by `quick`: fast structural checks without extra tooling.
quick_modes=(toc smoke changelog readme commands)

# Modes that only make sense after packaging; skipped by `all` and `list`.
post_package_modes=(worktree-clean)

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

# Prints every mode that `all` runs (and CI runs as a separate job), sorted.
list_modes() {
  local mode_name skip
  while IFS= read -r mode_name; do
    for skip in "${post_package_modes[@]}"; do
      [ "$mode_name" = "$skip" ] && continue 2
    done
    printf '%s\n' "$mode_name"
  done < <(printf '%s\n' "${script_modes[@]}" | sort)
}

print_help() {
  echo "Usage: bash ./scripts/check.sh [mode]"
  echo "Single-script modes:"
  printf '%s\n' "${script_modes[@]}" | sort | sed 's/^/  - /'
  echo "Grouped modes:"
  echo "  - quick (${quick_modes[*]})"
  echo "  - all (every mode except: ${post_package_modes[*]})"
  echo "Other:"
  echo "  - list (print the modes 'all' runs, one per line)"
}

mode="${1:-all}"
case "$mode" in
  -h|--help|help)
    print_help
    ;;
  list)
    list_modes
    ;;
  quick)
    for mode_name in "${quick_modes[@]}"; do
      run_script_mode "$mode_name"
    done
    ;;
  all)
    failed_modes=()
    while IFS= read -r mode_name; do
      if ! run_script_mode "$mode_name"; then
        failed_modes+=("$mode_name")
      fi
    done < <(list_modes)
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
