#!/usr/bin/env bash

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

function get_git_test_files() {

    local original_dir=$(pwd)
    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" || {
        cd "$original_dir"
        return 1
    }
    
    repo_root=$(get_repo_root)

    print_verbose "[git] Repo root: $repo_root"
    print_verbose "[git] Test file patterns: $TEST_FILE_PATTERN"

    files=$(
        git diff --name-only --diff-filter=ACMRT "$BASE_BRANCH"..."$CURRENT_BRANCH" -- "$TEST_FILE_PATTERN" \
        | awk -v root="$repo_root" 'NF{print root "/" $0}'
    )

    cd "$original_dir" 
    echo "$files"
}

function get_git_files() {

    local original_dir=$(pwd)
    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" || {
        cd "$original_dir"
        return 1
    }
    
    repo_root=$(get_repo_root)
    print_verbose "[git] Repo root: $repo_root"

    files=$(
        git diff --name-only --diff-filter=ACMRT "$BASE_BRANCH"..."$CURRENT_BRANCH" -- "$CODE_FILE_PATTERN" \
        | awk -v root="$repo_root" 'NF{print root "/" $0}'
    )

    cd "$original_dir" 
    echo "$files"
}


function get_repo_root() {
    local original_dir=$(pwd)
    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }

    repo_root=$(git rev-parse --show-toplevel) || {
        echo "❌ Not a git repo" >&2
        cd "$original_dir"
        return 1
    }

    cd "$original_dir" 
    echo "$repo_root"
}
