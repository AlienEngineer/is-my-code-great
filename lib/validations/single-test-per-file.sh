#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

# TODO: take into account other types of tests, not only testWidgets
#       e.g. test, testBloc, others?
function get_count_test_per_file() {
  grep -Frc 'testWidgets(' --include='*test.dart' "$dir" \
    | awk -F: '$2==1 {c++} END {print c+0}'
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "get_count_test_per_file" \
    "Files with 1 Test:"

