#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

register_validation \
    "pump-without-duration" \
    "LOW" \
    "find_text_in_dart_test 'tester.pump()' \"$dir\"" \
    "Pump without duration:"
