#!/usr/bin/env bash
set -euo pipefail


find_expects_in_the_middle_in_file() {
  local regex_pattern
  regex_pattern=$(get_test_function_pattern_names | tr ' ' '|')
  get_test_files \
    | xargs -r0 awk -v test_patterns="$regex_pattern" '
        function reset_block(){ in_test=0; depth=0; pending=0 }
        BEGIN { reset_block() }

        {
          pattern_regex = "^[[:space:]]*(" test_patterns ")([[:space:]]*<[^>]+>)?[[:space:]]*\\("
          if ($0 ~ pattern_regex) {
            in_test=1; depth=0; pending=0;
          }
        }

        {
          if (in_test) {
            if ($0 ~ /expect[[:space:]]*\(/) {
              pending=1
            }

            if (pending &&
                ($0 ~ /await[ \t]+tester\./ ||
                 $0 ~ /(^|[[:space:]])tester\.(tap|enterText|pumpAndSettle|pump|drag|longPress|fling|scroll|press|sendKeyEvent)\(/)) {
              printf("%s:%d: %s\n", file, NR ,$0)
              pending=0
            }

            for (i=1;i<=length($0);i++) {
              ch=substr($0,i,1)
              if (ch=="{") depth++
              else if (ch=="}") depth--
            }

            if (depth<=0) {
              pending=0
              reset_block()
            }
          }
        }
        END { }
      '
}

function _count_expect_in_middle() {
  local total=0

  while read -r line; do
    total=$((total + 1))
    add_details "$line"
  done < <(find_expects_in_the_middle_in_file)

  echo "$total"
}

register_test_validation \
    "expects-in-middle" \
    "LOW" \
    "_count_expect_in_middle" \
    "Expects in the middle:"