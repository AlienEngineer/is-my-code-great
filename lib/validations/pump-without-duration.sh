#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/validations/text-finders.sh"
source "$SCRIPT_ROOT/lib/validations/builder.sh"

register_validation \
    "pump-without-duration" \
    "LOW" \
    "find-text-in-dart-test 'tester.pump()' \"$dir\"" \
    "Pump without duration:"