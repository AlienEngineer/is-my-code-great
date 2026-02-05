#!/usr/bin/env bash
set -euo pipefail

function count_too_many_arguments() {
    local count=0
    while read -r line; do
        count=$((count + 1))
    done < <(get_code_files | xargs grep -En 'function\s+\w+\s*\([^)]*,[^)]*,[^)]*,[^)]*\)|const\s+\w+\s*=\s*\([^)]*,[^)]*,[^)]*,[^)]*\)\s*=>|=>\s*\([^)]*,[^)]*,[^)]*,[^)]*\)' 2>/dev/null)
    echo "$count"
}

register_code_validation \
    "too-many-arguments" \
    "MEDIUM" \
    "count_too_many_arguments" \
    "Functions with more than 3 arguments:"
