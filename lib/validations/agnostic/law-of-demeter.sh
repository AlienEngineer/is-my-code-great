#!/usr/bin/env bash

find_lines_that_violate_lod() {
  get_code_files \
    | xargs grep -nE '\b[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*){3,}\b' \
    | grep -vE 'using ' \
    | grep -vE 'namespace ' \
    | grep -vE 'assembly\: ' \
    | grep -vE "('[^']*'|\"[^\"]*\")"
}

function count_violations() {
  local total=0
  while read -r line; do
      add_details "$line"
      total=$(( total + 1 ))
  done < <(find_lines_that_violate_lod)

  echo "$total"
}

register_code_validation \
    "law-of-demeter" \
    "HIGH" \
    "count_violations" \
    "law-of-demeter (>2):"

