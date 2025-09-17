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
    function line_has_opening_brace(line) {
      return line ~ /[{][ \t]*$|[{][ \t]*\/\//
    }    
    /it\(/ { 
      #if (infunc) report(funcname, startline, NR - 1)
      inTest = 1
      infunc = 1
      startline = NR
      depth = 1
      funcname=$0
      wait_for_open_brace = 0
      next 
    }
    {
      {
        if (wait_for_open_brace && $0 ~ /{[ \t]*$/ || $0 ~ /^[ \t]*{[ \t]*$/) {
          depth = 1
          wait_for_open_brace = 0
        }
        for (i = 1; i <= length($0); i++) {
          c = substr($0, i, 1)
          if (c == "{") depth++
          if (c == "}") depth--
        }
        
        if (depth == 0 && NR > startline) {
          report(funcname, startline, NR-1)
          infunc = 0
          funcname = ""
          startline = 0
          wait_for_open_brace = 0
        }
      }
    }
    END { } 
  ' "$file"
}

find_big_functions() {  
  local files
  files="$(get_test_files)"

  for file in $files; do
    [[ -f "$file" ]] || continue
    find_big_tests_in_file "$file"
  done | sort -u
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
    "Test methods > 15 lines:"