#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

register_validation \
    "widgets-predicate" \
    "LOW" \
    "find_text_in_dart_test 'find.byWidgetPredicate(' \"$dir\"" \
    "Expect on predicate:"
