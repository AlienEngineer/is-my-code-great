#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"

function get_total_tests() {
  testWidgetsCount=$(find-text-in-dart-test 'testWidgets(' "$dir")
  testCount=$(grep -FoR --include='*.dart' 'test(' "$dir" | wc -l)
  testBlocCount=$(grep -FoR --include='*.dart' 'blocTest<' "$dir" | wc -l)
  testsCount=$((testWidgetsCount + testCount + testBlocCount))

  echo "$testsCount"
}