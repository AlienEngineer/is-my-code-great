#!/usr/bin/env bash
set -euo pipefail

# Source constants
# shellcheck source=lib/core/constants.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../core/constants.sh"

# Path to AWK script
BIG_TEST_AWK="$(dirname "${BASH_SOURCE[0]}")/../../awk/find_big_test_functions.awk"
readonly BIG_TEST_AWK

function find_big_functions() {  
  get_test_files \
    | xargs -r0 grep -nE 'test\('.*?',\s*\(\)( async)? \{|testWidgets\('.*?',\s*\(.*?\)( async)? \{|testGoldens\('.*?',\s*\(.*?\)( async)? \{|\}\);|.*?\(\(.*?\).*?\{' 2>/dev/null \
    | awk -v max_lines="$MAX_TEST_LINES" -f "$BIG_TEST_AWK"
}

function _count_big_test_methods() {
    local total=0
    while read -r line; do
        add_details "$line"
        total=$(( total + 1 ))
    done < <(find_big_functions)

    echo "$total"
}

register_test_validation \
    "big-test-files" \
    "HIGH" \
    "_count_big_test_methods" \
    "Big Tests (>${MAX_TEST_LINES} lines):"


