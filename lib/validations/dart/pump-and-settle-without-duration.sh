#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function _find_pump_and_settle_without_duration() {
    count=$(find_text_in_dart_test 'tester.pumpAndSettle()' "$dir" "$base_branch" "$current_branch")
    echo "$count"
}

register_validation \
    "pump-and-settle-without-duration" \
    "LOW" \
    "_find_pump_and_settle_without_duration" \
    "PumpAndSettle without duration:"
