#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function _find_widgets_predicate() {
    count=$(find_text_in_dart_test "find.byWidgetPredicate(" "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")
    echo "$count"
}

register_validation \
    "widgets-predicate" \
    "LOW" \
    "_find_widgets_predicate" \
    "Expect on predicate:"
