
#!/usr/bin/env bash

find_lines_that_violate_lod() {
  local -n batch="$1";

  print_verbose "  - Checking for Law of Demeter violations..."
  print_verbose "  - files: ${batch[@]}"

  grep -nE '\b[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*){3,}\b' -- "${batch[@]}" \
    | grep -vE 'using ' \
    | grep -vE 'namespace ' \
    | grep -vE 'assembly\: '
}

function count_violations() {
  local total=0
  while read -r line; do
      add_details "$line"
      total=$(( total + 1 ))
  done < <(iterate_code_files find_lines_that_violate_lod)

  echo "$total"
}

register_code_validation \
    "law-of-demeter" \
    "HIGH" \
    "count_violations" \
    "law-of-demeter (>2):"

