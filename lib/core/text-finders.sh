#!/usr/bin/env bash



function find-regex-in-dart-test() {
  local pattern="$1"
  local dir="${2:-.}"
  local count
  local count
  count=$(grep -RhoE "$pattern" --include='*test.dart' "$dir" | wc -l)
  echo "$((count+0))"
}

FIND_TEXT_TEST_IMPL="find-text-in-dart-test-for-local"

function use-git() {
  FIND_TEXT_TEST_IMPL="find-text-in-dart-test-for-local"
}

function use-local() {
  FIND_TEXT_TEST_IMPL="find-text-in-dart-test-for-local"
}

function find-text-in-dart-test() {
  "$FIND_TEXT_TEST_IMPL" "$@"
}

function find-text-in-dart-test-for-local() {
  local pattern="$1"
  local dir="${2:-.}"
  count=$(grep -FoR --include='*test.dart' "$pattern" "$dir" | wc -l)
  echo "$((count+0))"
}

function find-text-in-dart-test-for-git() {
  local base_branch="main"
  local current_branch="$(git rev-parse --abbrev-ref HEAD)"
  local dir="."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base)
        base_branch="$2"
        shift 2
        ;;
      --current)
        current_branch="$2"
        shift 2
        ;;
      --dir)
        dir="$2"
        shift 2
        ;;
      *)
        echo "❌ Unknown argument: $1"
        return 1
        ;;
    esac
  done

  local original_dir=$(pwd)
  cd "$dir" || {
    echo "❌ unable to find: $dir"
    return 1
  }

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌ '$dir' it's not a git repository."
    cd "$original_dir"
    return 1
  fi

  if ! git show-ref --verify --quiet "refs/heads/$base_branch"; then
    echo "❌ Base branch $base_branch not found."
    cd "$original_dir"
    return 1
  fi

  if ! git show-ref --verify --quiet "refs/heads/$current_branch"; then
    echo "❌ Current branch $current_branch not found."
    cd "$original_dir"
    return 1
  fi

  local files=$(git diff --name-only "$base_branch"..."$current_branch" -- '*_test.dart')

  local count=0

  for file in $files; do
    if [[ -f "$file" ]]; then
      count=$((count + $(grep -FoR "$pattern" "$file" | wc -l)))
    fi
  done
  
  cd "$original_dir"

  echo "$count"
}