#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/builder.sh"

run_analysis() {
    dir="${1:-.}"
    framework="$2"
    base_branch="$3"
    current_branch="$4"
    local_run="$5"

    # Source framework-specific core files
    if [ -f "$SCRIPT_ROOT/lib/core/$framework/text-finders.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/$framework/text-finders.sh"
    fi
    if [ -f "$SCRIPT_ROOT/lib/core/$framework/tests.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/$framework/tests.sh"
    fi

    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist."
        return 1
    fi

    if [ "$local_run" = true ]; then
        [ "$VERBOSE" = "1" ] && printf "Evaluating:\n$dir \n\n"
        use_local
    else
        [ "$VERBOSE" = "1" ] && printf "Evaluating: $base_branch vs $current_branch on dir: \n$dir \n\n"
        use_git
    fi

    VALIDATIONS_DIR="$SCRIPT_ROOT/lib/validations/$framework"
    if [ ! -d "$VALIDATIONS_DIR" ]; then
        echo "No validations found for framework: $framework" >&2
        return 1
    fi

    for script in "$VALIDATIONS_DIR"/*.sh; do
        [ -r "$script" ] && source "$script"
    done

    printf "\nIs my code great? "

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
