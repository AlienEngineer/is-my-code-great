#!/usr/bin/env bash

function find-text-in-dart-test() {
  local pattern="$1"
  local dir="${2:-.}"
  grep -FoR --include='*test.dart' "$pattern" "$dir" | wc -l
}

function find-regex-in-dart-test() {
  local pattern="$1"
  local dir="${2:-.}"
  grep -zoR --include='*test.dart' -E "$pattern" "$dir" | wc -l
}
