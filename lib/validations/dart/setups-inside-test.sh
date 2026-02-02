#!/usr/bin/env bash
set -euo pipefail


find_when_in_tests() {
  local regex_pattern
  regex_pattern=$(get_test_function_pattern_names | tr ' ' '|')
  get_code_files \
    | xargs awk -v test_patterns="$regex_pattern" '
    function get_line_number(line) {
      return NR
    }
    function reset_block(){ in_test=0; depth=0 }
    BEGIN { reset_block() }

    {
      pattern_regex = "^[[:space:]]*(" test_patterns ")([[:space:]]*<[^>]+>)?[[:space:]]*\\("
      if ($0 ~ pattern_regex) {
        in_test=1; depth=0;
      }
    }

    {
      if (in_test) {
        if ($0 ~ /when\(/) {
          printf("%s:%d: when(...) setup inside test method\n", FILENAME, NR)
        }

        for (i=1;i<=length($0);i++) {
          ch=substr($0,i,1)
          if (ch=="{") depth++
          else if (ch=="}") depth--
        }

        if (depth<=0) {
          reset_block()
        }
      }
    }
    END { }
  '
}

function count_when_in_tests() {
  local total=0
  while read -r line; do
    add_details "$line"
    total=$(( total + 1 ))
  done < <(find_when_in_tests)

  echo "$total"
}

register_test_validation \
    "setups-inside-test" \
    "HIGH" \
    "count_when_in_tests" \
    "Setups inside tests:"
