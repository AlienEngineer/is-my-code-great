set -euo pipefail


find_single_test_in_files() {
  get_code_files \
    | xargs grep -nE "test\(|testWidgets\(|testGoldens\(" \
    | awk '
        function get_file(line) {
          split(line, parts, ":")
          lineno = parts[1]
          return lineno
        }
        function get_line_number(line) {
          split(line, parts, ":")
          lineno = parts[2]
          return lineno
        }
        {
          if (count==0) {
            count=0
            previous_file=get_file($0)
            printf("init\n")
          }

          filename=get_file($0)
          if (previous_file == filename) {
            count++
          } else {
            if (count==1){
              printf("%s:%d \n", previous_file, get_line_number($0))
            }
            count=1        
          }

          previous_file=filename
        }
        END {
          if (count==1){
            printf("%s:%d \n", previous_file, get_line_number($0))
          }
        }
    '
}

function get_count_test_per_file() {
  local files
  files="$(get_test_files)"

  local total=0
  for file in $files; do
    [[ -f "$file" ]] || continue
    local c=0
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
      found=$(grep -Fo "$pattern" "$file" | wc -l);   
      c=$((c + found))
    done
    if [[ "$c" -eq 1 ]]; then 
      total=$((total+1))
      file_name="$(basename "$file")"
      add_details "$file:0: $file_name"
    fi
  done

  echo "$total"
}

register_test_validation \
    "tests-per-file" \
    "CRITICAL" \
    "get_count_test_per_file" \
    "Files with 1 Test:"

