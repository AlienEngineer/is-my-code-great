#!/usr/bin/env bash

function find-text-in-dart-test() {
  local pattern="$1"
  local dir="${2:-.}"
  count=$(grep -FoR --include='*test.dart' "$pattern" "$dir" | wc -l)
  echo "$((count+0))"
}

function find-regex-in-dart-test() {
  local pattern="$1"
  local dir="${2:-.}"
  local count
  local count
  count=$(grep -RhoE "$pattern" --include='*test.dart' "$dir" | wc -l)
  echo "$((count+0))"
}
