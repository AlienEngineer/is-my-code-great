#!/usr/bin/env bash

function _find_expect_on_keys() {
  local files
  files="$(get_files_to_analyse)"

  local total=0
  local IFS=$'\n'
  for file in $files; do
    [[ -f "$file" ]] || continue
    local c
    c=$(awk '
      /expect[[:space:]]*\(/ { want=1; if ($0 ~ /find\.byKey/) { count++; want=0 } next }
      want {
        if (/find\.byKey/) { count++; want=0 }
        else if (/;/)      { want=0 }
      }
      END { print count+0 }
    ' "$file")
    total=$((total + c))
  done
  unset IFS

  echo "$total"
}

register_validation \
    "expect-on-keys" \
    "HIGH" \
    "_find_expect_on_keys" \
    "Expectation on Keys:"
