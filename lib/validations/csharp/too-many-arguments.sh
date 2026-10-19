#!/usr/bin/env bash
set -euo pipefail

function count_too_many_arguments() {
    local awk_script
    awk_script="$(dirname "${BASH_SOURCE[0]}")/../../awk/find_too_many_arguments_csharp.awk"
    local count=0
    while read -r line; do
        count=$((count + 1))
    done < <(get_code_files | xargs -0 awk -f "$awk_script" 2>/dev/null)
    echo "$count"
}

register_code_validation \
    "too-many-arguments" \
    "MEDIUM" \
    "count_too_many_arguments" \
    "Methods with more than 3 arguments:"
