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
