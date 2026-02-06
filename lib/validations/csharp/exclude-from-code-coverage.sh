#!/usr/bin/env bash
set -euo pipefail


function count_exclusions() {
    find_text_in_files '[ExcludeFromCodeCoverage]'
}

register_test_validation \
    "exclude-from-code-coverage" \
    "HIGH" \
    "count_exclusions" \
    "Exclude from code coverage:"
