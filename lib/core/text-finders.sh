#!/usr/bin/env bash

function find_in_files() {
    local flags="$3"
    local pattern="$1"
    local files="$2"

    if [[ "${DETAILED:-}" == "true" ]]; then
        local count=0
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(grep $flags "$pattern" -- $files)
        echo "$count"
    else
        local count=$(grep $flags "$pattern" -- $files | wc -l)
        count=$((count))
        echo "$count"
    fi
}

function find_text_in_test() {
    find_in_files $1 "$(get_test_files_to_analyse)" -FnR
}

function find_regex_in_test() {
    find_in_files $1 "$(get_test_files_to_analyse)" -RnE
}

function find_text_in_files() {
    find_in_files $1 "$(get_files_to_analyse)" -FnR
}

function find_regex_in_files() {
    find_in_files $1 "$(get_files_to_analyse)" -RnE
}
