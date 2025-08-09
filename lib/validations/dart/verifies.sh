#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_verifies_count() {
    verifyCount=$(find_regex_in_dart_test 'verify\([^)]*\(\)[[:space:]]*=>' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")
    verifyNevercount=$(find_regex_in_dart_test 'verifyNever\([^)]*\(\)[[:space:]]*=>' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")

    echo $((verifyCount + verifyNevercount))
}

register_validation \
    "verifies" \
    "HIGH" \
    "get_verifies_count" \
    "Verify method calls:"
