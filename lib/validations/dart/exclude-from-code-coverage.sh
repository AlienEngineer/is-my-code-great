#!/usr/bin/env bash
set -euo pipefail


function count_exclusions() {
    find_text_in_test 'coverage:ignore-' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH"
}

register_test_validation \
    "exclude-from-code-coverage" \
    "HIGH" \
    "count_exclusions" \
    "Exclude from code coverage:"
