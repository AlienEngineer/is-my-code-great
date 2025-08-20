#!/usr/bin/env bash

get_find_by_key_lines() {
  local file="$1"
  awk -v file="$file" '
    /expect[[:space:]]*\(/ { want=1; if ($0 ~ /find\.byKey/) { 
      printf("%s:%d: %s\n", file, NR ,$0)
      want=0 
    } next }
    want {
      if (/find\.byKey/) { 
        #printf("%s:%d %s\n", file, NR,$0)
        want=0 
      }
      else if (/;/)      { want=0 }
    }
    END {  }
  ' "$file"
}

function _find_expect_on_keys() {
  local files
  files="$(get_test_files_to_analyse)"

  for file in $files; do
    get_find_by_key_lines "$file"
  done
}

function _count_expect_on_keys() {
  local total=0

  while read -r line; do
    total=$((total + 1))
    add_details "$line"
  done < <(_find_expect_on_keys)

  echo "$total"
}

register_test_validation \
    "expect-on-keys" \
    "HIGH" \
    "_count_expect_on_keys" \
    "Expectation on Keys:"

