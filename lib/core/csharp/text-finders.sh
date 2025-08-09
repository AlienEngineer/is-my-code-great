#!/usr/bin/env bash

FIND_TEXT_TEST_IMPL="find_text_in_csharp_test_for_local"

function find_text_in_csharp_test() {
    if [ "$LOCAL_RUN" == "true" ]; then 
        find_text_in_csharp_test_for_local "$@"
    else
        find_text_in_csharp_test_for_git "$@"
    fi
}

function find_text_in_csharp_test_for_local() {
    local pattern="$1"
    count=$(grep -FoR --include='*Test*.cs' "$pattern" "$DIR" | wc -l)
    echo "$((count + 0))"
}

function find_text_in_csharp_test_for_git() {
    local pattern="$1"

    local original_dir=$(pwd)

    _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" || {
        cd "$original_dir"
        return 1
    }

    local files=$(_get_git_files "$BASE_BRANCH" "$CURRENT_BRANCH")
    local count=0

    for file in $files; do
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -FoR "$pattern" "$file" | wc -l)))
        fi
    done

    cd "$original_dir"
    echo "$count"
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

function get_git_files() {
    local original_dir=$(pwd)
    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }

    repo_root=$(git rev-parse --show-toplevel)

    files=$(
        git diff --name-only "$BASE_BRANCH"..."$CURRENT_BRANCH" -- '*test*.cs' \
        | awk -v root="$repo_root" 'NF{print root "/" $0}'
    )

    cd "$original_dir" 
    echo "$files"
}
