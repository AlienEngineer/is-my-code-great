#!/usr/bin/env bash
set -euo pipefail


function _validate_git_repo() {
    local base="$1" current="$2"
    
    # Check if in a git repo
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "❌ Not a Git repo" >&2
        return 1
    fi
    
    # Validate base branch exists (check local, remote, or as commit)
    if ! git rev-parse --verify --quiet "$base" &>/dev/null && \
       ! git rev-parse --verify --quiet "refs/heads/$base" &>/dev/null && \
       ! git rev-parse --verify --quiet "refs/remotes/origin/$base" &>/dev/null; then
        echo "❌ Base branch '$base' not found" >&2
        return 1
    fi
    
    # Current branch validation is more lenient - HEAD is always valid in git
    if [[ "$current" != "HEAD" ]]; then
        if ! git rev-parse --verify --quiet "$current" &>/dev/null && \
           ! git rev-parse --verify --quiet "refs/heads/$current" &>/dev/null; then
            echo "❌ Current branch '$current' not found" >&2
            return 1
        fi
    fi
    
    return 0
}

function get_git_test_files() {

    local original_dir=$(pwd)
    cd "$DIR" 2>/dev/null || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    
    # Validate repo, but don't exit on failure - just return empty
    if ! _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" 2>/dev/null; then
        cd "$original_dir"
        return 1
    fi
    
    repo_root=$(get_repo_root)

    print_verbose "[git] Repo root: $repo_root"
    print_verbose "[git] Test file patterns: $TEST_FILE_PATTERN"

    files=$(
        git diff --name-only --diff-filter=ACMRT "$BASE_BRANCH"..."$CURRENT_BRANCH" -- "$TEST_FILE_PATTERN" 2>/dev/null \
        | awk -v root="$repo_root" 'NF{print root "/" $0}'
    )

    cd "$original_dir" 
    echo "$files"
}

function get_git_files() {

    local original_dir=$(pwd)
    cd "$DIR" 2>/dev/null || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    
    # Validate repo, but don't exit on failure - just return empty
    if ! _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" 2>/dev/null; then
        cd "$original_dir"
        return 1
    fi
    
    repo_root=$(get_repo_root)
    print_verbose "[git] Repo root: $repo_root"

    files=$(
        git diff --name-only --diff-filter=ACMRT "$BASE_BRANCH"..."$CURRENT_BRANCH" -- "$CODE_FILE_PATTERN" 2>/dev/null \
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
