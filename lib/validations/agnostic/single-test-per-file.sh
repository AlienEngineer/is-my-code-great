
function get_count_test_per_file() {
  local files
  files="$(get_files_to_analyse)"

  local total=0
  for file in $files; do
    [[ -f "$file" ]] || continue
    local c=0
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
      found=$(grep -Fo "$pattern" "$file" | wc -l);   
      c=$((c + found))
    done
    if [[ "$c" -eq 1 ]] then 
      total=$((total+1))
      file_name="$(basename "$file")"
      add_details "$file:0: $file_name"
    fi
  done

  echo "$total"
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "get_count_test_per_file" \
    "Files with 1 Test:"
