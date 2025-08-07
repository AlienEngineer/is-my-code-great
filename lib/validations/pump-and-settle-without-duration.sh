#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_count_pump_and_settle_without_duration() {
  count=$(find-regex-in-dart-test 'tester.pumpAndSettle()' "$dir")
  echo "$((count+0))"
}

register_validation \
    "pump-and-settle-without-duration" \
    "LOW" \
    "get_count_pump_and_settle_without_duration" \
    "PumpAndSettle without duration:"