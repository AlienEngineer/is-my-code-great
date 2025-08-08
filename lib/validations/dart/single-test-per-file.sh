#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function _get_count_test_per_file() {
    local total=0

    if [ "$VERBOSE" = "1" ]; then
        echo "\n[dart][single-test-per-file] Looking for dart files with exactly one testWidgets or test or testBloc method in files matching: *test.dart" >&2
    fi

    for pattern in 'testWidgets(' 'test(' 'testBloc<'; do
        count=$(grep -Frc "$pattern" --include='*test.dart' "$dir" |
            awk -F: '$2==1 {c++} END {print c+0}')
        total=$((total + count))
    done

    if [ "$VERBOSE" = "1" ]; then
        echo "\n[dart][single-test-per-file] Found $total files with exactly one testWidgets or test or testBloc method." >&2
    fi

    echo "$total"
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "_get_count_test_per_file" \
    "Files with 1 Test:"
