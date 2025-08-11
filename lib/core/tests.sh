#!/usr/bin/env bash

function get_total_tests() {
    local total=0
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
        count=$(find_text_in_test "$pattern" "$DIR")
        total=$((total + count))
    done
    echo "$total"
}
