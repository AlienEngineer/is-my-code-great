#!/usr/bin/env bash
set -euo pipefail


find_setups_in_tests() {
  get_test_files \
    | xargs -r0 grep -nE '\[TestMethod\]|public[[:space:]]+(void|async[[:space:]]+Task(<[^>]+>)?)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)|\{|\}|Setup\(' 2>/dev/null \
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
      funcname=""
      next 
    }
    inTest && funcname == "" && !/\[TestMethod\]/ {
      funcname=$0
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
        funcname=""
      }
      next
    }
    inTest && depth > 0 && /Setup\(/ {
      printf("%s:%d: Setup call inside test method\n", get_file($0), get_line_number($0))
    }
    '
}

function count_setups_in_tests() {
  local total=0
  while read -r line; do
      add_details "$line"
      total=$(( total + 1 ))
  done < <(find_setups_in_tests)

  echo "$total"
}

register_test_validation \
    "setups-inside-test" \
    "HIGH" \
    "count_setups_in_tests" \
    "Setups inside tests:"
