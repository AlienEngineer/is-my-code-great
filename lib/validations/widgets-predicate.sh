#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

register_validation \
    "widgets-predicate" \
    "LOW" \
    "find-text-in-dart-test 'find.byWidgetPredicate(' \"$dir\"" \
    "Expect on predicate:"