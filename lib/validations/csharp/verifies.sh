#!/usr/bin/env bash
set -euo pipefail


function get_verifies_count() {
    find_text_in_test '.Verify('
}

register_test_validation \
    "verifies" \
    "HIGH" \
    "get_verifies_count" \
    "Verify method calls:"
