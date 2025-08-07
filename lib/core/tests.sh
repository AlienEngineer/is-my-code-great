#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_total_tests() {
  local start=$(date +%s%N)
  
  testWidgetsCount=$(find-text-in-dart-test 'testWidgets(' "$dir")
  testCount=$(find-text-in-dart-test 'test(' "$dir")
  testBlocCount=$(find-text-in-dart-test 'blocTest<' "$dir")
  testsCount=$((testWidgetsCount + testCount + testBlocCount))
  
  totalTestsExecutionTime=$(( ( $(date +%s%N) - start ) / 1000000 ))

  echo "$testsCount"
}