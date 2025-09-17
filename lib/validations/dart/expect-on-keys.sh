#!/usr/bin/env bash

get_find_by_key_lines() {
  get_test_files \
    | grep -RnE "expect\(find.byKey\(" \
    | awk '
    {
      printf("%s:%d: %s\n", file, NR ,$0)
    }
    '
}

get_test_files() {
  if [ "${LOCAL_RUN:-false}" = true ]; then
    find "$DIR" -type f -name "$TEST_FILE_PATTERN"
  else
    repo_root=$(get_repo_root)
    git diff --name-only --diff-filter=ACMRT "$BASE_BRANCH"..."$CURRENT_BRANCH" -- "$TEST_FILE_PATTERN" \
      | awk -v root="$repo_root" '{print root "/" $0}'s
  fi
}

#function _count_expect_on_keys() {
#    local total=0
#    while read -r line; do
#        add_details "$line"
#        total=$(( total + 1 ))
#    done < <(get_find_by_key_lines)
#
#    echo "$total"
#}

#register_test_validation \
#    "expect-on-keys" \
#    "HIGH" \
#    "_count_expect_on_keys" \
#    "Expectation on Keys:"

get_test_files

get_find_by_key_lines