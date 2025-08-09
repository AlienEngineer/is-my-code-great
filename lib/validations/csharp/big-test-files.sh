#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_count_tests_long() {
    if [ "$VERBOSE" = "1" ]; then
        echo "\n[csharp][big-test-files] Looking for C# test methods > 15 lines in files matching: *Test*.cs" >&2
    fi

    testsLongCount=$(find "$DIR" -name '*Test*.cs' -print0 | xargs -0 awk '
    /\[TestMethod\]/ { inTest=1; lines=0; next }
    inTest {
      if (/^\s*\}/) { inTest=0; if (lines>15) count++ } else { lines++ }
    }
    END { print count+0 }
  ' | awk '{sum+=$1} END{print sum}')

    if [ "$VERBOSE" = "1" ]; then
        echo "\n[csharp][big-test-files] Found $testsLongCount test methods > 15 lines." >&2
    fi

    echo "$testsLongCount"
}

register_validation \
    "big-test-files" \
    "HIGH" \
    "get_count_tests_long" \
    "C# Test methods > 15 lines:"
