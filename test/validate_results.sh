#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <language>"
    echo "Example: $0 dart"
    exit 1
fi

LANGUAGE="$1"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

EXPECTED_RESULTS_FILE="$PROJECT_ROOT/test/$LANGUAGE/expected_results.sh"
EXAMPLES_DIR="$PROJECT_ROOT/examples/$LANGUAGE"

if [ ! -f "$EXPECTED_RESULTS_FILE" ]; then
    echo "Error: Expected results file not found: $EXPECTED_RESULTS_FILE"
    exit 1
fi

if [ ! -d "$EXAMPLES_DIR" ]; then
    echo "Error: Examples directory not found: $EXAMPLES_DIR"
    exit 1
fi

source "$EXPECTED_RESULTS_FILE"

cd "$EXAMPLES_DIR"
ACTUAL_RESULTS=$("$PROJECT_ROOT/bin/is-my-code-great" -p || true)

get_expected_count() {
    local key="$1"
    echo "$EXPECTED_RESULTS" | grep "^$key:" | cut -d: -f2 | tr -d ' ' || echo ""
}

get_actual_count() {
    local key="$1"
    echo "$ACTUAL_RESULTS" | grep "^$key=" | cut -d= -f2 | tr -d ' ' || echo ""
}

echo "Validating $LANGUAGE results..."
echo "================================"

EXIT_CODE=0

while IFS=: read -r expected_key expected_count; do
    expected_key=$(echo "$expected_key" | tr -d ' ')
    expected_count=$(echo "$expected_count" | tr -d ' ')

    actual_count=$(get_actual_count "$expected_key")
    [ -z "$actual_count" ] && actual_count="0"

    if [ "$actual_count" -eq "$expected_count" ]; then
        echo "✅ PASS: $expected_key (expected: $expected_count, actual: $actual_count)"
    else
        echo "❌ FAIL: $expected_key (expected: $expected_count, actual: $actual_count)"
        EXIT_CODE=1
    fi
done < <(echo "$EXPECTED_RESULTS" | grep ":")


while IFS= read -r line; do
    actual_key=$(echo "$line" | cut -d= -f1 | tr -d ' ')
    actual_value=$(echo "$line" | cut -d= -f2 | tr -d ' ')

    expected_count=$(get_expected_count "$actual_key")

    if [ -z "$expected_count" ]; then
        echo "⚠ WARNING: Unexpected result found: $actual_key=$actual_value"
    fi
    
done < <(echo "$ACTUAL_RESULTS" | grep "=")

echo "================================"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "All validations PASSED!"
else
    echo "Some validations FAILED!"
fi

exit "$EXIT_CODE"
