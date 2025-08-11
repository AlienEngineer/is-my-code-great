#!/usr/bin/env bash

function _find_pump_without_duration() {
    count=$(find_text_in_test 'tester.pump()' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")
    echo "$count"
}

register_validation \
    "pump-without-duration" \
    "LOW" \
    "_find_pump_without_duration" \
    "Pump without duration:"
