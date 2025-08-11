#!/usr/bin/env bash

function get_total_tests() {
    local start=$(date +%s%N)
    local testsCount=0
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
        count=$(find_text_in_test "$pattern" "$DIR")
        testsCount=$((testsCount + count))
    done

    totalTestsExecutionTime=$((($(date +%s%N) - start) / 1000000))
    echo "$testsCount"
}
