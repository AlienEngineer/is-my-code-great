#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function _get_count_test_per_file() {
  local total=0

  for pattern in 'testWidgets(' 'test(' 'testBloc<'; do
    count=$(grep -Frc "$pattern" --include='*test.dart' "$dir" \
      | awk -F: '$2==1 {c++} END {print c+0}')
    total=$((total + count))
  done

  echo "$total"
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "_get_count_test_per_file" \
    "Files with 1 Test:"

