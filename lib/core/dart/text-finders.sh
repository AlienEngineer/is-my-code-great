#!/usr/bin/env bash

declare -a TEST_PATTERNS=('testWidgets(' 'test(' 'testBloc<' 'testGoldens(')

# Format the patterns to remove any trailing characters like '<' or '(' and output them as a space separated string.
function get_test_patterns_names() {
    local -a names=()
    for pattern in "${TEST_PATTERNS[@]}"; do
        clean_name="${pattern%(*}"
        clean_name="${clean_name%<*}"
        names+=("$clean_name")
    done
    echo "${names[@]}"
}

function find_text_in_dart_test() {
    if [ "$LOCAL_RUN" = true ]; then
        find_text_in_dart_test_for_local "$@"
    else
        find_text_in_dart_test_for_git "$@"
    fi
}

function find_regex_in_dart_test() {
    if [ "$LOCAL_RUN" = true ]; then
        find_regex_in_dart_test_for_local "$@"
    else
        find_regex_in_dart_test_for_git "$@"
    fi
}

function find_regex_in_dart_test_for_local() {
    local pattern="$1"
    count=$(grep -RhoE "$pattern" --include='*test.dart' "$DIR" | wc -l)
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
    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }

    repo_root=$(get_repo_root)

    files=$(
        git diff --name-only "$BASE_BRANCH"..."$CURRENT_BRANCH" -- '*test.dart' \
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

function find_regex_in_dart_test_for_git() {
    local pattern="$1"

    local original_dir=$(pwd)

    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" || {
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
    count=$(grep -FoR "$pattern" --include='*test.dart' "$DIR" | wc -l)
    echo "$((count + 0))"
}

function find_text_in_dart_test_for_git() {
    local pattern="$1"

    local original_dir=$(pwd)

    cd "$DIR" || { echo "❌ Dir not found: $DIR" >&2; return 1; }
    _validate_git_repo "$BASE_BRANCH" "$CURRENT_BRANCH" || {
        cd "$original_dir"
        return 1
    }

    local files=$(get_git_files "$BASE_BRANCH" "$CURRENT_BRANCH")
    local count=0

    for file in $files; do
        if [[ -f "$file" ]]; then
            count=$((count + $(grep -FoR "$pattern" "$file" | wc -l)))
        fi
    done

    cd "$original_dir"
    echo "$count"
}
