#!/usr/bin/env bash

function sum_results() {
    local sum=0
    while read -r line; do
        sum=$((sum + line))
    done
    echo $sum
}

function sum_test_results() {
    local flags="$1"; shift
    local pattern="$1"; shift

    if [[ "${DETAILED:-}" == "true" ]]; then
        local count=0
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(get_test_files | xargs grep "$flags" "$pattern")
        echo "$count"
    else
        local count
        count=$( (get_test_files | xargs grep "${flags//R/c}" "$pattern" || echo 0) | sum_results)
        echo "$count"
    fi
}

function sum_code_results() {
    local flags="$1"; shift
    local pattern="$1"; shift

    if [[ "${DETAILED:-}" == "true" ]]; then
        local count=0
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(get_code_files | xargs grep "$flags" "$pattern")
        echo "$count"
    else
        local count
        count=$( (get_code_files | xargs grep "${flags//R/c}" "$pattern" || echo 0) | sum_results)
        echo "$count"
    fi
}

function find_text_in_test() {
    sum_test_results "-FnR" $1
}

function find_regex_in_test() { 
    sum_test_results "-nE" $1
}

function find_text_in_files() {
    sum_code_results "-FnR" $1
}

function find_regex_in_files() {
    sum_code_results "-nE" $1
}