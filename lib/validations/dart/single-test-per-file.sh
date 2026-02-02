set -euo pipefail

find_single_test_in_files() {
  get_code_files \
    | xargs grep -nE "test\(|testWidgets\(|testGoldens\("  \
    | awk '
        {
          split($0, parts, ":")
          file = parts[1]
          lineno = parts[2]
          if (prev_file != file && prev_file != "") {
            if (test_count == 1) {
              printf("%s:%d \n", prev_file, prev_lineno)
            }
            test_count = 0
          }
          prev_file = file
          prev_lineno = lineno
          test_count++
        }
        END {
          if (test_count == 1) {
            printf("%s:%d \n", prev_file, prev_lineno)
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

