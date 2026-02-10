#!/usr/bin/env bash
set -euo pipefail

# Source constants
# shellcheck source=lib/core/constants.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../core/constants.sh"

find_big_functions() { 
  get_test_files \
    | xargs -r0 grep -nE '\[TestMethod\]|public[[:space:]]+(void|async[[:space:]]+Task(<[^>]+>)?)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)|\{|\}' 2>/dev/null \
    | awk -v max_lines="$MAX_TEST_LINES" '
    function report(file, name, start, end) {
      if (name != "" && end >= start && (end - start) > max_lines) {
        printf("%s:%d: (%d lines) %s\n", file, start, end-start, name)
      }
    }
    function get_line_number(line) {
      split(line, parts, ":")
      lineno = parts[2]
      return lineno
    }
    function get_file(line) {
      split(line, parts, ":")
      lineno = parts[1]
      return lineno
    }
    function get_funcname(line) {
      split(line, parts, ":")
      lineno = parts[3]
      return lineno
    }
    /\[TestMethod\]/ { 
      inTest=1 
      count=0
      depth=0
      funcname=""
      next 
    }
    inTest && funcname == "" {
      funcname=get_funcname($0); next
    }
    inTest && /\{/ {
      if (depth == 0) {
        startline=get_line_number($0)+1
      }    
      depth++
      next
    }
    inTest && /\}/ {
      depth--
      if (depth == 0) {
        report(get_file($0), funcname, startline, get_line_number($0))
        inTest=0
        funcname=""
      }
    }
    '
}

function count_big_test_methods() {
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
    "count_big_test_methods" \
    "C# Test methods > ${MAX_TEST_LINES} lines:"

