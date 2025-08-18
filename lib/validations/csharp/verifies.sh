#!/usr/bin/env bash

function get_verifies_count() {
    verifyCount=$(find_text_in_test '.Verify(' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")

    echo $((verifyCount + 0))
}

register_validation \
    "verifies" \
    "HIGH" \
    "get_verifies_count" \
    "Verify method calls:"
