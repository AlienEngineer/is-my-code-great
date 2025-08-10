#!/usr/bin/env bash

function get_total_tests() {
    local start=$(date +%s%N)

    testCount=$(find_text_in_csharp_test '[TestMethod]' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")

    totalTestsExecutionTime=$((($(date +%s%N) - start) / 1000000))

    echo "$testCount"
}
