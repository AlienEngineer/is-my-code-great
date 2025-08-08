#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_total_tests() {
    local start=$(date +%s%N)

    testCount=$(find_text_in_csharp_test '[TestMethod]' "$dir" "$base_branch" "$current_branch")

    totalTestsExecutionTime=$((($(date +%s%N) - start) / 1000000))

    echo "$testCount"
}
