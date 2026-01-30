#!/usr/bin/env bash

function sum_test_results() {
    local flags="$1"; shift
    local pattern="$1"; shift

    # Validate inputs
    [[ -n "$flags" ]] || { echo "Error: flags required for sum_test_results" >&2; return 1; }
    [[ -n "$pattern" ]] || { echo "Error: pattern required for sum_test_results" >&2; return 1; }

    if [[ "${DETAILED:-}" == "true" ]]; then
        local count=0
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(get_test_files | xargs grep "$flags" "$pattern" 2>/dev/null)
        echo "$count"
    else
        get_test_files | xargs grep "$flags" "$pattern" 2>/dev/null | wc -l
    fi
}

function sum_code_results() {
    local flags="$1"; shift
    local pattern="$1"; shift

    # Validate inputs
    [[ -n "$flags" ]] || { echo "Error: flags required for sum_code_results" >&2; return 1; }
    [[ -n "$pattern" ]] || { echo "Error: pattern required for sum_code_results" >&2; return 1; }

    if [[ "${DETAILED:-}" == "true" ]]; then
        local count=0
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(get_code_files | xargs grep "$flags" "$pattern" 2>/dev/null)
        echo "$count"
    else
        get_code_files | xargs grep "$flags" "$pattern" 2>/dev/null | wc -l
    fi
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