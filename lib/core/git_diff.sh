#!/usr/bin/env bash
set -euo pipefail


function _validate_git_repo() {
    local dir="$1" base="$2" current="$3"
    
    # Check if in a git repo
    if ! git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null; then
        echo "❌ Not a Git repo: $dir" >&2
        return 1
    fi
    
    # Validate base branch exists (check local, remote, or as commit)
    if ! git -C "$dir" rev-parse --verify --quiet "$base" &>/dev/null && \
       ! git -C "$dir" rev-parse --verify --quiet "refs/heads/$base" &>/dev/null && \
       ! git -C "$dir" rev-parse --verify --quiet "refs/remotes/origin/$base" &>/dev/null; then
        echo "❌ Base branch '$base' not found in $dir" >&2
        return 1
    fi
    
    # Current branch validation is more lenient - HEAD is always valid in git
    if [[ "$current" != "HEAD" ]]; then
        if ! git -C "$dir" rev-parse --verify --quiet "$current" &>/dev/null && \
           ! git -C "$dir" rev-parse --verify --quiet "refs/heads/$current" &>/dev/null; then
            echo "❌ Current branch '$current' not found in $dir" >&2
            return 1
        fi
    fi
    
    return 0
}

function get_git_test_files() {
    # Validate directory exists
    [[ -d "$DIR" ]] || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    
    # Validate repo, but don't exit on failure - just return empty
    if ! _validate_git_repo "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH" 2>/dev/null; then
        return 1
    fi
    
    local repo_root
    repo_root=$(get_repo_root)

    print_verbose "[git] Repo root: $repo_root"
    print_verbose "[git] Test file patterns: $TEST_FILE_PATTERN"

    git -C "$DIR" diff --name-only --diff-filter=ACMRT "$BASE_BRANCH"..."$CURRENT_BRANCH" -- "$TEST_FILE_PATTERN" 2>/dev/null \
        | awk -v root="$repo_root" 'NF{print root "/" $0}'
}

function get_git_files() {
    # Validate directory exists
    [[ -d "$DIR" ]] || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    
    # Validate repo, but don't exit on failure - just return empty
    if ! _validate_git_repo "$DIR" "$BASE_BRANCH" "$CURRENT_BRANCH" 2>/dev/null; then
        return 1
    fi
    
    local repo_root
    repo_root=$(get_repo_root)
    print_verbose "[git] Repo root: $repo_root"

    git -C "$DIR" diff --name-only --diff-filter=ACMRT "$BASE_BRANCH"..."$CURRENT_BRANCH" -- "$CODE_FILE_PATTERN" 2>/dev/null \
        | awk -v root="$repo_root" 'NF{print root "/" $0}'
}


function get_repo_root() {
    # Validate directory exists
    [[ -d "$DIR" ]] || { echo "❌ Dir not found: $DIR" >&2; return 1; }

    git -C "$DIR" rev-parse --show-toplevel 2>/dev/null || {
        echo "❌ Not a git repo: $DIR" >&2
        return 1
    }
}
