#!/usr/bin/env bash

get_find_by_key_lines() {
  get_test_files | xargs grep -nE "expect\(\s*find.byKey\(" \
    | awk '
    {
      printf("%s:%d: %s\n", file, NR ,$0)
    }
    '
}

function _count_expect_on_keys() {
    local total=0
    while read -r line; do
        add_details "$line"
        total=$(( total + 1 ))
    done < <(get_find_by_key_lines)

    echo "$total"
}

register_test_validation \
    "expect-on-keys" \
    "HIGH" \
    "_count_expect_on_keys" \
    "Expectation on Keys:"



get_test_files | xargs grep -nE "expect\(\s*find.byKey\("