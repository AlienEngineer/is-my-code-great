#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function _get_count_expect_on_keys() {
    expectKeysCount=$(find "$dir" -name '*test.dart' -exec awk '
    /expect[[:space:]]*\(/ { want=1; if ($0 ~ /find\.byKey/) { count++; want=0 } next }
    want {
      if (/find\.byKey/) { count++; want=0 }
      else if (/;/)    { want=0 }
    }
    END { print count }
  ' {} + | awk '{sum+=$1} END{print sum}')
    echo "$expectKeysCount"
}

function _get_count_expect_on_keys_git() {
  local original_dir
  original_dir=$(pwd)
  cd "$dir" || { echo "❌ Dir not found: $dir" >&2; return 1; }

  _validate_git_repo "$base_branch", "$current_branch" || { cd "$original_dir"; return 1; }

  local files
  files="$(get_git_files "$base_branch" "$current_branch")"

  local total=0
  local IFS=$'\n'
  for file in $files; do
    [[ -f "$file" ]] || continue
    local c
    c=$(awk '
      /expect[[:space:]]*\(/ { want=1; if ($0 ~ /find\.byKey/) { count++; want=0 } next }
      want {
        if (/find\.byKey/) { count++; want=0 }
        else if (/;/)      { want=0 }
      }
      END { print count+0 }
    ' "$file")
    total=$((total + c))
  done
  unset IFS

  cd "$original_dir"
  echo "$total"
}

function _find_expect_on_keys() {
    if [ "$local_run" ]; then
        _get_count_expect_on_keys
    else
        _get_count_expect_on_keys_git
    fi
}

register_validation \
    "expect-on-keys" \
    "HIGH" \
    "_find_expect_on_keys" \
    "Expectation on Keys:"
