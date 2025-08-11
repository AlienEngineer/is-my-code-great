#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_total_tests() {
    local start=$(date +%s%N)
    local testsCount=0
    for pattern in "${TEST_PATTERNS[@]}"; do
        count=$(find_text_in_dart_test "$pattern" "$DIR")
        testsCount=$((testsCount + count))
    done
    totalTestsExecutionTime=$((($(date +%s%N) - start) / 1000000))
    echo "$testsCount"
}
