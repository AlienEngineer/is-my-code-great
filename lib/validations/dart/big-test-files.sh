#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPT_ROOT/lib/core/dart/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_count_test_widgets_long() {
  find "$dir" -name '*test.dart' -exec awk -v threshold=15 '
    /testWidgets/ {
      inBlock=1
      brace = gsub(/\{/, "") - gsub(/\}/, "")
      lines=0
      next
    }
    inBlock {
      brace += gsub(/\{/, "") - gsub(/\}/, "")
      if (brace>0) lines++
      else {
        count += (lines>threshold)
        inBlock=0
      }
    }
    END { print count+0 }
  ' {} \+ \
  | awk '{sum += $1} END {print sum}'
}

function get_count_tests_long() {
  if [ "$VERBOSE" = "1" ]; then
    echo "\n[dart][big-test-files] Looking for Dart test functions > 15 lines in files matching: *test.dart" >&2
  fi

  testsLongCount=$(find "$dir" -name '*test.dart' -print0 | xargs -0 awk '
    /test\(/ {
      inBlock=1
      nOpen = gsub(/\{/, "")
      nClose = gsub(/\}/, "")
      brace = nOpen - nClose
      lines=0
      next
    }
    inBlock {
      nOpen = gsub(/\{/, "")
      nClose = gsub(/\}/, "")
      brace += nOpen - nClose
      if (brace>0) lines++
      else {
        count += (lines>15)
        inBlock=0
      }
    }
    END { print count+0 }
  ' | awk '{sum+=$1} END{print sum}')

  if [ "$VERBOSE" = "1" ]; then
    echo "\n[dart][big-test-files] Found $testsLongCount test functions > 15 lines." >&2
  fi

  echo "$testsLongCount"
}
