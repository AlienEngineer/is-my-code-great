#!/usr/bin/env bash

function get_total_tests() {
    local total=0
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
        count=$(find_text_in_test "$pattern" "$DIR")
        total=$((total + count))
    done
    echo "$total"
}

# Format the test function patterns to remove any trailing characters like '<' or '(' and output them
# as a space separated string.
function get_test_function_pattern_names() {
    local -a names=()
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
        clean_name="${pattern%(*}"
        clean_name="${clean_name%<*}"
        names+=("$clean_name")
    done
    echo "${names[@]}"
}
