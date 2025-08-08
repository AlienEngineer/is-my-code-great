#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function _get_count_test_per_file() {
    local total=0

    if [ "$VERBOSE" = "1" ]; then
        echo "\n[dart][single-test-per-file] Looking for dart files with exactly one testWidgets or test or testBloc method in files matching: *test.dart" >&2
    fi

    for pattern in 'testWidgets(' 'test(' 'testBloc<'; do
        count=$(grep -Frc "$pattern" --include='*test.dart' "$dir" |
            awk -F: '$2==1 {c++} END {print c+0}')
        total=$((total + count))
    done

    if [ "$VERBOSE" = "1" ]; then
        echo "\n[dart][single-test-per-file] Found $total files with exactly one testWidgets or test or testBloc method." >&2
    fi

    echo "$total"
}

function _get_count_test_per_file_git() {
  local original_dir
  original_dir=$(pwd)
  cd "$dir" || { echo "❌ Dir not found: $dir" >&2; return 1; }

  _validate_git_repo "$base_branch" "$current_branch" || { cd "$original_dir"; return 1; }

  [ "$VERBOSE" = "1" ] && echo -e "\n[dart][single-test-per-file] (git) base=$base_branch current=$current_branch" >&2

  local files
  files="$(get_git_files "$base_branch" "$current_branch")"

  local total=0
  local IFS=$'\n'
  for file in $files; do
    [[ -f "$file" ]] || continue

    local c
    c=$(grep -Fo 'testWidgets(' "$file" | wc -l); [[ "$c" -eq 1 ]] && total=$((total+1))
    c=$(grep -Fo 'test('        "$file" | wc -l); [[ "$c" -eq 1 ]] && total=$((total+1))
    c=$(grep -Fo 'testBloc<'    "$file" | wc -l); [[ "$c" -eq 1 ]] && total=$((total+1))
  done
  unset IFS

  [ "$VERBOSE" = "1" ] && echo -e "\n[dart][single-test-per-file] (git) Found $total files (per-pattern exactly one occurrence)." >&2

  cd "$original_dir"
  echo "$total"
}

function _find_single_test_per_file() {
    if [ "$local_run" = true ]; then
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
