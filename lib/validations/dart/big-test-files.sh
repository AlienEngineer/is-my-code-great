#!/usr/bin/env bash

function _find_big_functions() {
  MAX_LINES="${2:-15}"
  local file="$1"
  awk -v max="$MAX_LINES" -v file="$file" '
      function report(name, start, end) {
        if (name != "" && end >= start && (end - start + 1) > max) {
          printf("(%d) - %d-%d (%d lines): %s\n", max, start, end, end-start+1, name)
        }
      }
      function line_has_opening_brace(line) {
        return line ~ /[{][ \t]*$|[{][ \t]*\/\//
      }
      /^[ \t]*(Future<.*>|Stream<.*>|void|int|double|bool|String|List<.*>|Map<.*>|dynamic|var)?[ \t]+[A-Za-z0-9_<>]+\s*\([^)]*\)[ \t]*(async)?[ \t]*[{]?[ \t]*$/ {
        if (infunc) report(funcname, startline, NR - 1)
        infunc = 1
        startline = NR
        funcname = $0
        depth = 0
        if (line_has_opening_brace($0)) {
          depth = 1
        } else {
          wait_for_open_brace = 1
        }
        next
      }
      {
        if (infunc) {
          if (wait_for_open_brace && $0 ~ /^[ \t]*{/) {
            depth = 1
            wait_for_open_brace = 0
          }
          for (i = 1; i <= length($0); i++) {
            c = substr($0, i, 1)
            if (c == "{") depth++
            if (c == "}") depth--
          }
          if (depth == 0) {
            report(funcname, startline, NR)
            infunc = 0
            funcname = ""
            startline = 0
            wait_for_open_brace = 0
          }
        }
      }
      END {
        if (infunc) report(funcname, startline, NR)
      }
    ' "$file"
}

function find_big_functions_git() {
  local max_lines="${MAX_LINES:-15}"
  
  local files
  files="$(get_files_to_analyse)"

  for file in $files; do
    [[ -f "$file" ]] || continue
    _find_big_functions "$file"
  done | sort -u
}

function _count_big_test_methods() {
  local total=0
  while read -r line; do
      for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
        local count=0
        count=$(printf "%s\n" "$line" | grep -F "$pattern" | wc -l)
        total=$(( total + count ))
      done
  done < <(find_big_functions_git)

  echo "$total"
}

register_validation \
    "big-test-files" \
    "HIGH" \
    "_count_big_test_methods" \
    "Big Tests (>15 lines):"
