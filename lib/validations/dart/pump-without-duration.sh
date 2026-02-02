#!/usr/bin/env bash
set -euo pipefail


function _find_pump_without_duration() {
    find_text_in_test 'tester.pump()' "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH"    
}

register_test_validation \
    "pump-without-duration" \
    "LOW" \
    "_find_pump_without_duration" \
    "Pump without duration:"
