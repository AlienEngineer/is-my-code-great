#!/usr/bin/env bash

function get_total_tests() {
    local start=$(date +%s%N)

    testWidgetsCount=$(find_text_in_test 'testWidgets(' "$DIR")
    testCount=$(find_text_in_test 'test(' "$DIR")
    testBlocCount=$(find_text_in_test 'blocTest<' "$DIR")
    testsCount=$((testWidgetsCount + testCount + testBlocCount))

    totalTestsExecutionTime=$((($(date +%s%N) - start) / 1000000))

    echo "$testsCount"
}
