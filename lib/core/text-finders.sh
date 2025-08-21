#!/usr/bin/env bash

function find_in_files() {
    local flags="$1"; shift
    local pattern="$1"; shift
    local -n batch="$1";

    if [[ "${DETAILED:-}" == "true" ]]; then
        local count=0
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(grep $flags "$pattern" -- "${batch[@]}")
        echo "$count"
    else
        local count=$(grep $flags "$pattern" -- "${batch[@]}" | wc -l)
        count=$((count))
        echo "$count"
    fi
}

function sum_test_results() {
    local flags="$1"; shift
    local pattern="$1"; shift

    local total=0
    while IFS= read -r n; do
        (( total += n ))
    done < <(iterate_test_files find_in_files "$flags" $pattern)

    echo "$total"
}

function sum_code_results() {
    local flags="$1"; shift
    local pattern="$1"; shift

    local total=0
    while IFS= read -r n; do
        (( total += n ))
    done < <(iterate_code_files find_in_files "$flags" $pattern)

    echo "$total"
}

function find_text_in_test() {
    sum_test_results "-FnR" $1
}

function find_regex_in_test() { 
    sum_test_results "-RnE" $1
}

function find_text_in_files() {
    sum_code_results "-FnR" $1
}

function find_regex_in_files() {
    sum_code_results "-RnE" $1
}