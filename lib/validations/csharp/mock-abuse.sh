#!/usr/bin/env bash

find_mock_fields() {
  get_code_files \
    | xargs grep -nE 'Mock<|TestMethod\]|public[[:space:]]+(void|async[[:space:]]+Task(<[^>]+>)?)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)|\{|\}' \
    | awk '
    function get_line_number(line) {
      split(line, parts, ":")
      return parts[2]
    }
    function get_file(line) {
      split(line, parts, ":")
      return parts[1]
    }
    /\[TestMethod\]/ { 
      inTest=1 
      depth=0
      next 
    }
    inTest && /\{/ {
      depth++
      next
    }
    inTest && /\}/ {
      depth--
      if (depth == 0) {
        inTest=0
      }
      next
    }
    !inTest && depth == 0 && /Mock</ {
      printf("%s:%d: Mock field at class level\n", get_file($0), get_line_number($0))
    }
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
    "Mock<...> fields declared at class level:"
