#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_count_pump_and_settle_without_duration() {
  count=$(find_regex_in_dart_test 'tester.pumpAndSettle()' "$dir")
  echo "$((count+0))"
}

register_validation \
    "pump-and-settle-without-duration" \
    "LOW" \
    "get_count_pump_and_settle_without_duration" \
    "PumpAndSettle without duration:"
