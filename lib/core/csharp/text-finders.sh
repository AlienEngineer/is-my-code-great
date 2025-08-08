#!/usr/bin/env bash

function find_text_in_csharp_test() {
  local pattern="$1"
  local dir="${2:-.}"

  count=$(grep -FoR --include='*Test*.cs' "$pattern" "$dir" | wc -l)
  echo "$((count+0))"
}
