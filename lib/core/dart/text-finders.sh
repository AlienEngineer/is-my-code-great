#!/usr/bin/env bash

FIND_TEXT_TEST_IMPL="find_text_in_dart_test_for_local"
FIND_REGEX_TEST_IMPL="find_regex_in_dart_test_for_local"

function find_text_in_dart_test() {
    "$FIND_TEXT_TEST_IMPL" "$@"
}

function find_regex_in_dart_test() {
    "$FIND_REGEX_TEST_IMPL" "$@"
}

function use_git() {
    FIND_TEXT_TEST_IMPL="find_text_in_dart_test_for_git"
    FIND_REGEX_TEST_IMPL="find_regex_in_dart_test_for_git"
}

function use_local() {
    FIND_TEXT_TEST_IMPL="find_text_in_dart_test_for_local"
    FIND_REGEX_TEST_IMPL="find_regex_in_dart_test_for_local"
}

function find_regex_in_dart_test_for_local() {
    local pattern="$1"
    local dir="${2:-.}"
    count=$(grep -RhoE "$pattern" --include='*test.dart' "$dir" | wc -l)
    echo "$((count + 0))"
}

function _validate_git_repo() {
    local base="$1" current="$2"
    git rev-parse --is-inside-work-tree &>/dev/null || {
        echo "❌ Not a Git repo"
        return 1
    }
    git show-ref --verify --quiet "refs/heads/$base" || {
        echo "❌ Base branch '$base' not found"
        return 1
    }
    git show-ref --verify --quiet "refs/heads/$current" || {
        echo "❌ Current branch '$current' not found"
        return 1
    }
    return 0
}

function _get_git_files() {
    local base_branch="$1"
    local current_branch="$2"
    git diff --name-only "$base_branch"..."$current_branch" -- '*_test.dart'
}

function find_regex_in_dart_test_for_git() {
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
                echo "❌ Unknown arg: $1"
                return 1
                ;;
        esac
    done

    local original_dir=$(pwd)
    cd "$dir" || {
        echo "❌ unable to find: $dir"
        return 1
    }

    _validate_git_repo "$base_branch" "$current_branch" || {
        cd "$original_dir"
        return 1
    }

    local files=$(_get_git_files "$base_branch" "$current_branch")
    local count=0

    for file in $files; do
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -RhoE "$pattern" --include='*test.dart' "$file" | wc -l)))
        fi
    done

    cd "$original_dir"
    echo "$count"
}

function find_text_in_dart_test_for_local() {
    local pattern="$1"
    local dir="${2:-.}"
    count=$(grep -FoR "$pattern" --include='*test.dart' "$dir" | wc -l)
    echo "$((count + 0))"
}

function find_text_in_dart_test_for_git() {
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
                echo "❌ Unknown arg: $1"
                return 1
                ;;
        esac
    done

    local original_dir=$(pwd)
    cd "$dir" || {
        echo "❌ unable to find: $dir"
        return 1
    }

    _validate_git_repo "$base_branch" "$current_branch" || {
        cd "$original_dir"
        return 1
    }

    local files=$(_get_git_files "$base_branch" "$current_branch")
    local count=0

    for file in $files; do
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -FoR "$pattern" "$file" | wc -l)))
        fi
    done

    cd "$original_dir"
    echo "$count"
}
