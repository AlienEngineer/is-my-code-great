#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_total_tests() {
  local start=$(date +%s%N)
  
  testWidgetsCount=$(find_text_in_dart_test 'testWidgets(' "$dir")
  testCount=$(find_text_in_dart_test 'test(' "$dir")
  testBlocCount=$(find_text_in_dart_test 'blocTest<' "$dir")
  testsCount=$((testWidgetsCount + testCount + testBlocCount))
  
  totalTestsExecutionTime=$(( ( $(date +%s%N) - start ) / 1000000 ))

  echo "$testsCount"
}
