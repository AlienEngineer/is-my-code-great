#!/usr/bin/env bash

function get_count_test_per_file() {
    count=$(
        find "$DIR" -name '*Test*.cs' -print0 | xargs -0 awk '
    /\[TestMethod\]/ {n++}
    ENDFILE {if (n==1) c++; n=0}
    END {print c+0}'
    )
    echo "$count"
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "get_count_test_per_file" \
    "Files with 1 Test:"
