#!/usr/bin/env bash

function _get_count_test_per_file() {
    local total=0

    if [ "$VERBOSE" = "1" ]; then
      echo "\n[dart][single-test-per-file] Looking for dart files with exactly one test method (patterns: $(get_test_function_pattern_names)) in files matching: $TEST_FILE_PATTERN)" >&2
    fi

    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
        count=$(grep -Frc "$pattern" --include="$TEST_FILE_PATTERN" "$DIR" |
            awk -F: '$2==1 {c++} END {print c+0}')
        total=$((total + count))
    done

    if [ "$VERBOSE" = "1" ]; then
        echo "\n[dart][single-test-per-file] Found $total files with exactly one test method (patterns: $(get_test_function_pattern_names))." >&2
    fi

    echo "$total"
}

function _get_count_test_per_file_git() {
  local original_dir
  original_dir=$(pwd)
  cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }

  _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" || { cd "$original_dir"; return 1; }

  [ "$VERBOSE" = "1" ] && echo -e "\n[dart][single-test-per-file] (git) base=$BASE_BRANCH current=$CURRENT_BRANCH" >&2

  local files
  files="$(get_git_files "$BASE_BRANCH" "$CURRENT_BRANCH")"

  local total=0
  local IFS=$'\n'
  for file in $files; do
    [[ -f "$file" ]] || continue
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
      c=$(grep -Fo "$pattern" "$file" | wc -l); [[ "$c" -eq 1 ]] && total=$((total+1))
    done
  done
  unset IFS

  [ "$VERBOSE" = "1" ] && echo -e "\n[dart][single-test-per-file] (git) Found $total files (per-pattern exactly one occurrence)." >&2

  cd "$original_dir"
  echo "$total"
}

function _find_single_test_per_file() {
    if [ "$LOCAL_RUN" = true ]; then
        _get_count_test_per_file
    else
        _get_count_test_per_file_git
    fi
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "_find_single_test_per_file" \
    "Files with 1 Test:"
