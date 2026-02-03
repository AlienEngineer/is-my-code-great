#!/usr/bin/env bash
set -euo pipefail

# Use BASH_SOURCE for correct path resolution (works in sourced contexts like bats)
SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/verbosity.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"
source "$SCRIPT_ROOT/lib/core/report/terminal.sh"


_source_framework_config() {
    local framework="$1"
    
    if [ -z "$framework" ]; then
        echo "Framework parameter required" >&2
        return 1
    fi
    
    local config_file="$SCRIPT_ROOT/lib/core/$framework/config.sh"
    if [ -f "$config_file" ]; then
        source "$config_file"
        return 0
    fi
    
    echo "Config file not found: $config_file" >&2
    return 1
}

_source_core_utilities() {
    local core_files=(
        "$SCRIPT_ROOT/lib/core/files.sh"
        "$SCRIPT_ROOT/lib/core/git_diff.sh"
        "$SCRIPT_ROOT/lib/core/text-finders.sh"
        "$SCRIPT_ROOT/lib/core/tests.sh"
        "$SCRIPT_ROOT/lib/core/report/html.sh"
    )
    
    for file in "${core_files[@]}"; do
        if [ -f "$file" ]; then
            source "$file"
        else
            echo "Core file not found: $file" >&2
            return 1
        fi
    done
    
    if [[ "${DETAILED:-}" == "true" ]]; then
        local details_file="$SCRIPT_ROOT/lib/core/details.sh"
        if [ -f "$details_file" ]; then
            source "$details_file"
        else
            echo "Details file not found: $details_file" >&2
            return 1
        fi
    else
        local details_stub="$SCRIPT_ROOT/lib/core/details_stub.sh"
        if [ -f "$details_stub" ]; then
            source "$details_stub"
        else
            echo "Details stub not found: $details_stub" >&2
            return 1
        fi
    fi
    
    return 0
}

_load_validations() {
    local framework="$1"
    
    if [ -z "$framework" ]; then
        echo "Framework parameter required" >&2
        return 1
    fi
    
    local validations_dir="$SCRIPT_ROOT/lib/validations/$framework"
    if [ ! -d "$validations_dir" ]; then
        echo "No validations found for framework: $framework" >&2
        return 1
    fi

    for script in "$validations_dir"/*.sh; do
        [ -r "$script" ] && source "$script"
    done
    
    local agnostic_dir="$SCRIPT_ROOT/lib/validations/agnostic"
    for script in "$agnostic_dir"/*.sh; do
        [ -r "$script" ] && source "$script"
    done
    
    return 0
}

_report_results() {
    local parseable="$1"
    
    if [ "$parseable" = "1" ]; then
        print_validations_parseable
        return 0
    fi

    printf "\nIs my code great? "
    print_summary
    export_report
    
    return 0
}

run_analysis() {
    # shellcheck disable=SC2153
    if [ ! -d "$DIR" ]; then
        echo "Directory $DIR does not exist." >&2
        return 1
    fi
    
    # shellcheck disable=SC2153
    _source_framework_config "$FRAMEWORK" || return 1
    _source_core_utilities || return 1
    # shellcheck disable=SC2153
    _load_validations "$FRAMEWORK" || return 1
    # shellcheck disable=SC2153
    _report_results "$PARSEABLE" || return 1
    
    return 0
}
