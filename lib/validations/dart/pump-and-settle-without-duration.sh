#!/usr/bin/env bash
set -euo pipefail


function _find_pump_and_settle_without_duration() {
    find_text_in_test 'tester.pumpAndSettle()'
}

register_test_validation \
    "pump-and-settle-without-duration" \
    "LOW" \
    "_find_pump_and_settle_without_duration" \
    "PumpAndSettle without duration:"
