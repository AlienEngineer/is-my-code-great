#!/usr/bin/env bash

function count_exclusions() {
    coverage=$(find_text_in_files '[ExcludeFromCodeCoverage]' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")

    echo $((coverage + 0))
}

register_test_validation \
    "exclude-from-code-coverage" \
    "HIGH" \
    "count_exclusions" \
    "Exclude from code coverage:"
