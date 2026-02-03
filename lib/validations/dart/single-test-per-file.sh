set -euo pipefail

# Path to AWK script
readonly SINGLE_TEST_AWK="$(dirname "${BASH_SOURCE[0]}")/../../awk/find_single_test_files.awk"

find_single_test_in_files() {
  get_code_files \
    | xargs grep -nE "test\(|testWidgets\(|testGoldens\(" \
    | awk -f "$SINGLE_TEST_AWK"
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

