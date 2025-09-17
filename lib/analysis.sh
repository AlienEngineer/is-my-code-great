#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/verbosity.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"
source "$SCRIPT_ROOT/lib/core/report/terminal.sh"


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
    if [[ "${DETAILED:-}" == "true" ]]; then
        if [ -f "$SCRIPT_ROOT/lib/core/details.sh" ]; then
            source "$SCRIPT_ROOT/lib/core/details.sh"
        fi
    else
        if [ -f "$SCRIPT_ROOT/lib/core/details_stub.sh" ]; then
            source "$SCRIPT_ROOT/lib/core/details_stub.sh"
        fi
    fi
    if [ -f "$SCRIPT_ROOT/lib/core/report/html.sh" ]; then
        source "$SCRIPT_ROOT/lib/core/report/html.sh"
    fi

    if [ ! -d "$DIR" ]; then
        echo "Directory $DIR does not exist."
        return 1
    fi

    VALIDATIONS_DIR="$SCRIPT_ROOT/lib/validations/$FRAMEWORK"
    if [ ! -d "$VALIDATIONS_DIR" ]; then
        echo "No validations found for framework: $FRAMEWORK" >&2
        return 1
    fi

    for script in "$VALIDATIONS_DIR"/*.sh; do
        [ -r "$script" ] && source "$script"
    done
    
    VALIDATIONS_DIR="$SCRIPT_ROOT/lib/validations/agnostic"
    for script in "$VALIDATIONS_DIR"/*.sh; do
        [ -r "$script" ] && source "$script"
    done

    if [ "$PARSEABLE" = "1" ]; then
        print_validations_parseable
        return 0
    fi

    printf "\nIs my code great? "

    dump_summary
    #export_report
}
