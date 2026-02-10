#!/usr/bin/env bash
set -euo pipefail

function count_too_many_arguments() {
    local count=0
    while read -r line; do
        count=$((count + 1))
    done < <(get_code_files | xargs -0 grep -En '(public|private|protected|internal).*\([^)]*,[^)]*,[^)]*,[^)]*\)' 2>/dev/null | grep -v '//.*\([^)]*,[^)]*,[^)]*,[^)]*\)')
    echo "$count"
}

register_code_validation \
    "too-many-arguments" \
    "MEDIUM" \
    "count_too_many_arguments" \
    "Methods with more than 3 arguments:"
