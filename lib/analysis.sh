#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/builder.sh"

run_analysis() {

    # Source framework-specific core files
    if [ -f "$SCRIPT_ROOT/lib/core/$FRAMEWORK/config.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/$FRAMEWORK/config.sh"
    fi

    # Souce tech agnostic core files
    # These files can only be sourced after config.sh is sourced
    if [ -f "$SCRIPT_ROOT/lib/core/files.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/files.sh"
    fi
    if [ -f "$SCRIPT_ROOT/lib/core/git_diff.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/git_diff.sh"
    fi
    if [ -f "$SCRIPT_ROOT/lib/core/text-finders.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/text-finders.sh"
    fi
    if [ -f "$SCRIPT_ROOT/lib/core/tests.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/tests.sh"
    fi
    if [ -f "$SCRIPT_ROOT/lib/core/details.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/details.sh"
    fi

    if [ ! -d "$DIR" ]; then
        echo "Directory $DIR does not exist."
        return 1
    fi

    init_details_file

    VALIDATIONS_DIR="$SCRIPT_ROOT/lib/validations/$FRAMEWORK"
    if [ ! -d "$VALIDATIONS_DIR" ]; then
        echo "No validations found for framework: $FRAMEWORK" >&2
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

    finish_details_file
    open_details_file
}
