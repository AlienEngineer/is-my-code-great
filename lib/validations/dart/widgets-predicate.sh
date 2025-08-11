#!/usr/bin/env bash

function _find_widgets_predicate() {
    count=$(find_text_in_test "find.byWidgetPredicate(" "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH")
    echo "$count"
}

register_validation \
    "widgets-predicate" \
    "LOW" \
    "_find_widgets_predicate" \
    "Expect on predicate:"
