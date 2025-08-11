#!/usr/bin/env bash

function get_total_tests() {
    testCount=$(find_text_in_test '[TestMethod]' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")
    echo "$testCount"
}
