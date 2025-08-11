#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"

MAX_LINES="${2:-15}"
function find_big_functions() {
    find "$DIR" \
        -type f \
        -name '*test.dart' \
        -not -path '*/.git/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' \
        -not -path '*/dist/*' \
        -not -path '*/build/*' \
        -not -path '*/.next/*' \
        -not -path '*/.venv/*' \
        -not -path '*/target/*' \
        -print0 |
        while IFS= read -r -d '' file; do
            awk -v max="$max_lines" -v file="$file" '
      function report(name, start, end) {
        if (name != "" && end >= start && (end - start + 1) > max) {
          printf("%s:%d-%d (%d lines): %s\n", file, start, end, end-start+1, name)
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
        done | sort -u
}

function get_count_big_test_methods() {
  local list total=0
  list="$(mktemp)"; trap 'rm -f "$list"' EXIT
  find_big_functions | cut -d: -f1 | sort -u > "$list"

  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    for pattern in "${TEST_PATTERNS[@]}"; do
      total=$(( total + $(grep -hoF "$pattern" "$file" | wc -l) ))
    done
  done < "$list"

  echo "$total"
}
function find_big_functions_git() {
  local max_lines="${MAX_LINES:-15}"
  
  local files
  files="$(get_git_files "$BASE_BRANCH" "$CURRENT_BRANCH")"

  local IFS=$'\n'
  for file in $files; do
    [[ -f "$file" ]] || continue
    awk -v max="$max_lines" -v file="$file" '
      function report(name, start, end) {
        if (name != "" && end >= start && (end - start + 1) > max) {
          printf("%s:%d-%d (%d lines): %s\n", file, start, end, end-start+1, name)
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
  done | sort -u
  unset IFS
}

# Git-based variant of the counter, mirroring get_count_big_test_methods
function get_count_big_test_methods_git() {

  local list total=0
  list="$(mktemp)"; trap 'rm -f "$list"' RETURN

  find_big_functions_git --base "$BASE_BRANCH" --current "$CURRENT_BRANCH" --dir "$DIR" --max "$max_lines" \
    | cut -d: -f1 | sort -u > "$list"

  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    for pattern in "${TEST_PATTERNS[@]}"; do
      total=$(( total + $(grep -hoF "$pattern" "$file" | wc -l) ))
    done
  done < "$list"

  echo "$total"
}

function find_count_big_test_methods() {
    if [ "$LOCAL_RUN" = true ]; then
        get_count_big_test_methods
    else
        get_count_big_test_methods_git
    fi
}

register_validation \
    "big-test-files" \
    "HIGH" \
    "find_count_big_test_methods" \
    "Big Tests (>15 lines):"
