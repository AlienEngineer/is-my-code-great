#!/usr/bin/env bash

function get_verifies_count() {
    find_text_in_test '.Verify(' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH"
}

#register_test_validation \
#    "verifies" \
#    "HIGH" \
#    "get_verifies_count" \
#    "Verify method calls:"
