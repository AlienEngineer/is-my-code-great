#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_count_test_per_file() {
    if [ "$VERBOSE" = "1" ]; then
        echo "\n[csharp][single-test-per-file] Looking for C# files with exactly one [TestMethod] method in files matching: *Test*.cs" >&2
    fi

    count=$(
        find "$DIR" -name '*Test*.cs' -print0 | xargs -0 awk '
    /\[TestMethod\]/ {n++}
    ENDFILE {if (n==1) c++; n=0}
    END {print c+0}'
    )

    if [ "$VERBOSE" = "1" ]; then
        echo "\n[csharp][single-test-per-file] Found $count files with exactly one [TestMethod] method." >&2
    fi

    echo "$count"
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "get_count_test_per_file" \
    "Files with 1 Test:"
