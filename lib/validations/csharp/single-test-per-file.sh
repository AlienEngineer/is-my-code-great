
find_single_test_in_files() {
  local -n batch="$1";
  grep -nE "\[TestMethod\]|public[[:space:]]+(void|async[[:space:]]+Task(<[^>]+>)?)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)" -- "${batch[@]}" \
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
        }
        
        #printf("%s (%d) \n", get_file($0), count)

        filename=get_file($0)
        if (previous_file == filename) {
          count++
        } else {
          if (count==2){
            printf("%s:%d \n", previous_file, get_line_number($0))
          }
          count=1        
        }

        previous_file=filename
      }
      END {
        if (count==2){
          printf("%s:%d \n", previous_file, get_line_number($0))
        }
      }
  '
}

function count_single_test_methods() {
  local total=0
  while read -r line; do
      add_details "$line"
      total=$(( total + 1 ))
  done < <(iterate_test_files find_single_test_in_files)

  echo "$total"
}

register_test_validation \
    "tests-per-file" \
    "CRITICAL" \
    "count_single_test_methods" \
    "Files with 1 Test:"


