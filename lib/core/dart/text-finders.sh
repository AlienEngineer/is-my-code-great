#!/usr/bin/env bash

function find_text_in_dart_test() {
    if [ "$Local_run" = true ]; then
        find_text_in_dart_test_for_local "$@"
    else
        find_text_in_dart_test_for_git "$@"
    fi
}

function find_regex_in_dart_test() {
    if [ "$Local_run" = true ]; then
        find_regex_in_dart_test_for_local "$@"
    else
        find_regex_in_dart_test_for_git "$@"
    fi
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
        echo "❌ Not a Git repo" >&2
        return 1
    }
    git show-ref --verify --quiet "refs/heads/$base" || {
        echo "❌ Base branch '$base' not found" >&2
        return 1
    }
    git show-ref --verify --quiet "refs/heads/$current" || {
        echo "❌ Current branch '$current' not found" >&2
        return 1
    }
    return 0
}

function get_git_files() {

    local original_dir=$(pwd)
    cd "$dir" || { echo "❌ Dir not found: $dir" >&2; return 1; }

    repo_root=$(git rev-parse --show-toplevel)

    files=$(
        git diff --name-only "$base_branch"..."$current_branch" -- '*test.dart' \
        | awk -v root="$repo_root" 'NF{print root "/" $0}'
    )


    cd "$original_dir" 
    echo "$files"
}

function find_regex_in_dart_test_for_git() {
    local pattern="$1"
    local dir="${2:-.}"
    local base_branch="${3:-main}"
    local current_branch="${4:-$(git rev-parse --abbrev-ref HEAD)}"

    local original_dir=$(pwd)

    cd "$dir" || { echo "❌ Dir not found: $dir" >&2; return 1; }
    _validate_git_repo "$base_branch" "$current_branch" || {
        cd "$original_dir"
        return 1
    }

    local files=$(get_git_files)
    local count=0

    for file in $files; do
        # Ensure the file exists before grepping
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -RhoE "$pattern" --include='*test.dart' "$file" | wc -l)))
        else
            echo "❌ File not found: $file" >&2
            continue
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
    local pattern="$1"

    local original_dir=$(pwd)

    cd "$dir" || { echo "❌ Dir not found: $dir" >&2; return 1; }
    _validate_git_repo "$base_branch" "$current_branch" || {
        cd "$original_dir"
        return 1
    }

    local files=$(get_git_files "$base_branch" "$current_branch")
    local count=0

    for file in $files; do
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -FoR "$pattern" "$file" | wc -l)))
        fi
    done

    cd "$original_dir"
    echo "$count"
}
