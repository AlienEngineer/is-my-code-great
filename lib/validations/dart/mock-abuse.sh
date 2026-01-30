#!/usr/bin/env bash

find_mock_fields() {
  local regex_pattern
  regex_pattern=$(get_test_function_pattern_names | tr ' ' '|')
  get_code_files \
    | xargs awk -v test_patterns="$regex_pattern" '
    function reset_block(){ in_test=0; depth=0 }
    BEGIN { reset_block(); class_level_depth=0 }

    {
      pattern_regex = "^[[:space:]]*(" test_patterns ")([[:space:]]*<[^>]+>)?[[:space:]]*\\("
      if ($0 ~ pattern_regex) {
        in_test=1; depth=0;
      }
    }

    {
      if (in_test) {
        for (i=1;i<=length($0);i++) {
          ch=substr($0,i,1)
          if (ch=="{") depth++
          else if (ch=="}") depth--
        }

        if (depth<=0) {
          reset_block()
        }
      }
      else {
        for (i=1;i<=length($0);i++) {
          ch=substr($0,i,1)
          if (ch=="{") class_level_depth++
          else if (ch=="}") class_level_depth--
        }

        if (class_level_depth > 0 && $0 ~ /Mock[A-Za-z0-9_]+\(/) {
          printf("%s:%d: Mock field at class level\n", FILENAME, NR)
        }
      }
    }
    END { }
  '
}

function count_mock_fields() {
  local total=0
  while read -r line; do
    add_details "$line"
    total=$(( total + 1 ))
  done < <(find_mock_fields)

  echo "$total"
}

register_test_validation \
    "mock-abuse" \
    "HIGH" \
    "count_mock_fields" \
    "Mock abuse:"
