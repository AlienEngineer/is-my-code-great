#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_verifies_count() {
 verifyCount=$(find-regex-in-dart-test 'verify\([^)]*\(\)[[:space:]]*=>' "$dir")
 verifyNevercount=$(find-regex-in-dart-test 'verifyNever\([^)]*\(\)[[:space:]]*=>' "$dir")
 echo $((verifyCount + verifyNevercount))
}

register_validation \
    "verifies" \
    "HIGH" \
    "get_verifies_count" \
    "Verify method calls:"

