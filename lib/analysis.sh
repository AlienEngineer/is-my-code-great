#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"
source "$SCRIPT_ROOT/lib/core/tests.sh"

run_analysis() {
  
  local dir="${1}"
  local base_branch="${2}"
  local current_branch="${3}"
  local local_run="${4}"
  
  if [ ! -d "$dir" ]; then
    echo "Directory $dir does not exist."
    return 1
  fi

  if [ "$local_run" = true ]; then
    printf "Evaluating:\n$dir \n\n"
    use_local
  else
    printf "Evaluating: $base_branch vs $current_branch on dir: \n$dir \n\n"
    use_git
  fi
  
  printf "Is my code great? "
  VALIDATIONS_DIR="$SCRIPT_ROOT/lib/validations"
  for script in "$VALIDATIONS_DIR"/*.sh; do
    [ -r "$script" ] && source "$script"
  done

  local totalTests=$(get_total_tests)
  local totalIssues=$(get_total_issues)
  if [ "$totalIssues" -gt 0 ]; then
    printf "Nop!\n\n"

    printf "%-40s %10d\n" "Total Tests:" "$totalTests"
    print_validations
  else
    echo "Oh My God! You've done good!"
  fi

  printf "\n\nCode evaluated in %d ms\n" "$(get_total_execution_time)"
}
