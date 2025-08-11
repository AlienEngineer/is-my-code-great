#!/usr/bin/env bash

function find_text_in_test() {
    if [ "$LOCAL_RUN" = true ]; then
        find_text_in_test_for_local "$@"
    else
        find_text_in_test_for_git "$@"
    fi
}

function find_regex_in_test() {
    if [ "$LOCAL_RUN" = true ]; then
        find_regex_in_test_for_local "$@"
    else
        find_regex_in_test_for_git "$@"
    fi
}

function find_regex_in_test_for_local() {
    local pattern="$1"
    count=$(grep -RhoE "$pattern" --include="$TEST_FILE_PATTERN" "$DIR" | wc -l)
    echo "$((count + 0))"
}

function find_regex_in_test_for_git() {
    local pattern="$1"

    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }

    local files=$(get_git_files)
    local count=0

    for file in $files; do
        # Ensure the file exists before grepping
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -RhoE "$pattern" "$file" | wc -l)))
        else
            echo "❌ File not found: $file" >&2
            continue
        fi
    done
    echo "$count"
}

function find_text_in_test_for_local() {
    local pattern="$1"
    count=$(grep -FoR "$pattern" --include="$TEST_FILE_PATTERN" "$DIR" | wc -l)
    echo "$((count + 0))"
}

function find_text_in_test_for_git() {
    local pattern="$1"

    local files=$(get_git_files "$BASE_BRANCH" "$CURRENT_BRANCH")
    local count=0

    for file in $files; do
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -FoR "$pattern" "$file" | wc -l)))
        fi
    done

    echo "$count"
}
