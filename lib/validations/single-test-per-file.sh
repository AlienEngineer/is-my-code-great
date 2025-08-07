#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

# TODO: take into account other types of tests, not only testWidgets
#       e.g. test, testBloc, others?
function get_count_test_per_file() {
  singleTestWidgetsFilesCount=0
  while IFS= read -r -d '' file; do
    cnt=$(grep -Fo 'testWidgets(' "$file" | wc -l)
    if [ "$cnt" -eq 1 ]; then
      singleTestWidgetsFilesCount=$((singleTestWidgetsFilesCount+1))
    fi
  done < <(find "$dir" -name '*.dart' -print0)
  echo "$singleTestWidgetsFilesCount"
}

register_validation \
    "tests-per-file" \
    "CRITICAL" \
    "get_count_test_per_file" \
    "Files with 1 Test:"

