#!/usr/bin/env bash

function find_text_in_test() {
    local pattern="$1"
    local files=$(get_test_files_to_analyse)
    local count=0
    for file in $files; do
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(grep -FnR "$pattern" "$file")
    done
    echo "$count"
}

function find_regex_in_test() {
    local pattern="$1"
    local files=$(get_test_files_to_analyse)
    local count=0
    for file in $files; do
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(grep -RnE "$pattern" "$file")
    done
    echo "$count"
}


function find_text_in_files() {
    local pattern="$1"
    local files=$(get_files_to_analyse)
    local count=0
    for file in $files; do
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(grep -FnR "$pattern" "$file")
    done
    echo "$count"
}

function find_regex_in_files() {
    local pattern="$1"
    local files=$(get_files_to_analyse)
    local count=0
    for file in $files; do
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(grep -RnE "$pattern" "$file")
    done
    echo "$count"
}
