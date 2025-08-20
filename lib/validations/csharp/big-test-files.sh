#!/usr/bin/env bash

find_big_tests_in_file() {
  MAX_LINES="${2:-15}"
  local file="$1"
  awk -v max="$MAX_LINES" -v file="$file" '
    function report(name, start, end) {
      if (name != "" && end >= start && (end - start) > max) {
        printf("%s:%d: (%d lines) %s\n", file, start, end-start, name)
      }
    }
    /\[TestMethod\]/ { inTest=1; count=0; next }
    /^[ \t]*public (void|async[ \t]+Task)[ \t]+[A-Za-z0-9_]+[ \t]*\(\)[ \t]*$/ {
      funcname=$0
      startline=NR
    }
    /^[[:space:]]*}/ { 
        if (inTest) {
            report(funcname, startline, NR - 1)
        }
        inTest=0 
    }
    inTest {
        count++ 
    }
  ' "$file"
}

find_big_functions() {  
  local files
  files="$(get_test_files_to_analyse)"

  for file in $files; do
    find_big_tests_in_file "$file"
  done
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
    "C# Test methods > 15 lines:"

# find_big_functions