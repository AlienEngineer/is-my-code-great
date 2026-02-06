#!/usr/bin/env bash
set -euo pipefail


function get_verifies_count() {
    find_regex_in_test 'verify\(|verifyNever\('
}

register_test_validation \
    "verifies" \
    "HIGH" \
    "get_verifies_count" \
    "Verify method calls:"
