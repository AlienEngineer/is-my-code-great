#!/usr/bin/env bash

function find_text_in_dart_test() {
  local pattern="$1"
  local dir="${2:-.}"
  count=$(grep -FoR --include='*test.dart' "$pattern" "$dir" | wc -l)
  echo "$((count+0))"
}

function find_regex_in_dart_test() {
  local pattern="$1"
  local dir="${2:-.}"
  count=$(grep -RhoE "$pattern" --include='*test.dart' "$dir" | wc -l)
  echo "$((count+0))"
}
