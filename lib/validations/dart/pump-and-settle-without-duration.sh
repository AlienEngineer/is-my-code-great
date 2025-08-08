#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

register_validation \
    "pump-and-settle-without-duration" \
    "LOW" \
    "find-text-in-dart-test 'tester.pumpAndSettle()' \"$dir\"" \
    "PumpAndSettle without duration:"
