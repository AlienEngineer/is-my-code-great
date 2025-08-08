#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_verifies_count() {
    verifyCount=$(find_regex_in_dart_test 'verify\([^)]*\(\)[[:space:]]*=>' "$dir" "$base_branch" "$current_branch")
    verifyNevercount=$(find_regex_in_dart_test 'verifyNever\([^)]*\(\)[[:space:]]*=>' "$dir" "$base_branch" "$current_branch")
    echo $((verifyCount + verifyNevercount))
}

register_validation \
    "verifies" \
    "HIGH" \
    "get_verifies_count" \
    "Verify method calls:"
