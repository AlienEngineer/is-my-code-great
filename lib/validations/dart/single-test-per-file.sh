#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

# TODO: take into account other types of tests, not only testWidgets
#       e.g. test, testBloc, others?
function get_count_test_per_file() {
  if [ "$VERBOSE" = "1" ]; then
    echo "\n[dart][single-test-per-file] Looking for Dart files with exactly one testWidgets in files matching: *test.dart" >&2
  fi

  count=$(grep -Frc 'testWidgets(' --include='*test.dart' "$dir" | awk -F: '$2==1 {c++} END {print c+0}')

  if [ "$VERBOSE" = "1" ]; then
    echo "\n[dart][single-test-per-file] Found $count files with exactly one testWidgets." >&2
  fi

  echo "$count"
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "get_count_test_per_file" \
    "Files with 1 Test:"
