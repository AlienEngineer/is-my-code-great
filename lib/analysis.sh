#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"
source "$SCRIPT_ROOT/lib/core/tests.sh"

run_analysis() {
  
  dir="${1:-.}"

  if [ ! -d "$dir" ]; then
    echo "Directory $dir does not exist."
    return 1
  fi

  VALIDATIONS_DIR="$SCRIPT_ROOT/lib/validations"
  for script in "$VALIDATIONS_DIR"/*.sh; do
    [ -r "$script" ] && source "$script"
  done

  local totalIssues=$(get_total_issues)
  if [ "$totalIssues" -gt 0 ]; then
    printf "Nop!\n\n"

    local totalTests=$(get_total_tests)
    printf "%-40s %4d\n" "Total Tests:" "$totalTests"
    print_validations
  else
    echo "Oh My God! You've done good!"
  fi

  printf "\n\nCode evaluated in %d ms\n" "$(get_total_execution_time)"
}
