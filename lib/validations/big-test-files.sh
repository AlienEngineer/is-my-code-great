#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

function get_count_test_widgets_long() {
  testWidgetsLongCount=$(find "$dir" -name '*test.dart' -print0 | xargs -0 awk '
    /testWidgets/ {
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
        if (lines>15) count++
        inBlock=0
      }
    }
    END {print count+0}
  ' | awk '{sum+=$1} END{print sum}')
  echo "$testWidgetsLongCount"
}

function get_count_tests_long() {
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
        if (lines>15) count++
        inBlock=0
      }
    }
    END {print count+0}
  ' | awk '{sum+=$1} END{print sum}')
  echo "$testsLongCount"
}

function get_count_build_long() {
  buildLongCount=$(find "$dir" -name '*test.dart' -print0 | xargs -0 awk '
    /blocTest[[:space:]]*(<[^>]+>)?[[:space:]]*\(/ { inBloc=1; next }
    /build:[[:space:]]*\(\)[[:space:]]*\{/ && inBloc {
        inBuild=1
        nOpen   = gsub(/\{/, "")
        nClose  = gsub(/\}/, "")
        brace   = nOpen - nClose
        lines   = 0
        next
    }
    inBuild {
        nOpen   = gsub(/\{/, "")
        nClose  = gsub(/\}/, "")
        brace  += nOpen - nClose
        if (brace > 0) lines++
        else {
            if (lines > 5) count++
            inBuild=0
            inBloc=0
        }
    }
    END { print count+0 }
    ' | awk '{sum+=$1} END{print sum}')
  echo "$buildLongCount"
}



function get_count_big_test_methods() {
  testWidgetsLongCount=$(get_count_test_widgets_long) || 0
  testsLongCount=$(get_count_tests_long) || 0
  buildLongCount=$(get_count_build_long) || 0

  echo "$(($testWidgetsLongCount + buildLongCount + testsLongCount))"
}

register_validation \
    "big-test-files" \
    "HIGH" \
    "get_count_big_test_methods" \
    "Big Tests (>15 lines):"

