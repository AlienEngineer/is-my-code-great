#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

# TODO: take into account other types of tests, not only testWidgets
#       e.g. test, testBloc, others?
function _get_count_expect_on_keys() {
    expectKeysCount=$(find "$dir" -name '*test.dart' -exec awk '
    /expect[[:space:]]*\(/ { want=1; if ($0 ~ /find\.byKey/) { count++; want=0 } next }
    want {
      if (/find\.byKey/) { count++; want=0 }
      else if (/;/)    { want=0 }
    }
    END { print count }
  ' {} + | awk '{sum+=$1} END{print sum}')
    echo "$expectKeysCount"
}

register_validation \
    "expect-on-keys" \
    "HIGH" \
    "_get_count_expect_on_keys" \
    "Expectation on Keys:"
