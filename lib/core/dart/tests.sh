#!/usr/bin/env bash

function get_total_tests() {
    testWidgetsCount=$(find_text_in_test 'testWidgets(' "$DIR")
    testCount=$(find_text_in_test 'test(' "$DIR")
    testBlocCount=$(find_text_in_test 'blocTest<' "$DIR")
    testsCount=$((testWidgetsCount + testCount + testBlocCount))
    echo "$testsCount"
}
