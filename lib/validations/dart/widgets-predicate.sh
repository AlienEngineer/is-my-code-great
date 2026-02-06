#!/usr/bin/env bash
set -euo pipefail


function _find_widgets_predicate() {
    find_text_in_test "find.byWidgetPredicate("
}

register_test_validation \
    "widgets-predicate" \
    "LOW" \
    "_find_widgets_predicate" \
    "Expect on predicate:"
