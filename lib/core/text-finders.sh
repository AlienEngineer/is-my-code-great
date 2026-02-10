#!/usr/bin/env bash
set -euo pipefail

# Internal helper to eliminate duplication between sum_test_results and sum_code_results
_sum_results() {
    local file_getter="$1"; shift
    local flags="$1"; shift
    local pattern="$1"; shift

    # Validate inputs
    [[ -n "$file_getter" ]] || { echo "Error: file_getter required for _sum_results" >&2; return 1; }
    [[ -n "$flags" ]] || { echo "Error: flags required for _sum_results" >&2; return 1; }
    [[ -n "$pattern" ]] || { echo "Error: pattern required for _sum_results" >&2; return 1; }

    if [[ "${DETAILED:-}" == "true" ]]; then
        local count=0
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <("$file_getter" | xargs -r0 grep "$flags" "$pattern" 2>/dev/null || true)
        echo "$count"
    else
        # Count lines, defaulting to 0 if grep finds nothing
        local count
        count=$("$file_getter" | xargs -r0 grep "$flags" "$pattern" 2>/dev/null | wc -l)
        # Trim whitespace and handle empty/error cases
        count="${count// /}"
        echo "${count:-0}"
    fi
}

function sum_test_results() {
    local flags="$1"; shift
    local pattern="$1"; shift
    _sum_results get_test_files "$flags" "$pattern"
}

function sum_code_results() {
    local flags="$1"; shift
    local pattern="$1"; shift
    _sum_results get_code_files "$flags" "$pattern"
}

function find_text_in_test() {
    sum_test_results "-FnR" "$1"
}

function find_regex_in_test() { 
    sum_test_results "-nE" "$1"
}

function find_text_in_files() {
    sum_code_results "-FnR" "$1"
}

function find_regex_in_files() {
    sum_code_results "-nE" "$1"
}