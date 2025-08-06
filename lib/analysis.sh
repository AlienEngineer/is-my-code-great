#!/usr/bin/env bash

run_analysis() {
  
  dir="${1:-.}"
  expectKeysCount=$(find "$dir" -name '*.dart' -exec awk '
    /expect[[:space:]]*\(/ { want=1; if ($0 ~ /find\.byKey/) { count++; want=0 } next }
    want {
      if (/find\.byKey/) { count++; want=0 }
      else if (/;/)    { want=0 }
    }
    END { print count }
  ' {} +)
  pumpWithoutDuration=$(grep -FoR --include='*.dart' 'tester.pump()' "$dir" | wc -l)
  pumpAndSettleWithoutDuration=$(grep -FoR --include='*.dart' 'tester.pumpAndSettle()' "$dir" | wc -l)
  widgetPredicate=$(grep -FoR --include='*.dart' 'find.byWidgetPredicate(' "$dir" | wc -l)
  verifyArrowCount=$(grep -zoR --include='*.dart' -E 'verify\([^)]*\(\)[[:space:]]*=>' "$dir" | wc -l)
  verifyNeverArrowCount=$(grep -zoR --include='*.dart' -E 'verifyNever\([^)]*\(\)[[:space:]]*=>' "$dir" | wc -l)
  singleTestWidgetsFilesCount=0
  while IFS= read -r -d '' file; do
    cnt=$(grep -Fo 'testWidgets(' "$file" | wc -l)
    if [ "$cnt" -eq 1 ]; then
      singleTestWidgetsFilesCount=$((singleTestWidgetsFilesCount+1))
    fi
  done < <(find "$dir" -name '*.dart' -print0)
  testWidgetsLongCount=$(find "$dir" -name '*.dart' -print0 | xargs -0 awk '
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
  ')
  testsLongCount=$(find "$dir" -name '*.dart' -print0 | xargs -0 awk '
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
  ')
buildLongCount=$(find "$dir" -name '*.dart' -print0 | xargs -0 awk '
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
')




  testWidgetsCount=$(grep -FoR --include='*.dart' 'testWidgets(' "$dir" | wc -l)
  testCount=$(grep -FoR --include='*.dart' 'test(' "$dir" | wc -l)
  testBlocCount=$(grep -FoR --include='*.dart' 'blocTest<' "$dir" | wc -l)
  testsCount=$((testWidgetsCount + testCount + testBlocCount))

  total=$((
    expectKeysCount + 
    testWidgetsLongCount + 
    pumpWithoutDuration + 
    pumpAndSettleWithoutDuration + 
    verifyArrowCount+verifyNeverArrowCount + 
    singleTestWidgetsFilesCount +
    widgetPredicate +
    buildLongCount +
    testsLongCount
  ))

  if [ "$total" -gt 0 ]; then
    printf "Nop!\n\n"
    printf "Tests Found: $testsCount\n"
    printf "%-40s %4s %-10s\n" "Issues on Tests:" "#" "Severity"
    printf "%-40s %4d %-10s\n" "Pump without Duration:" "$pumpWithoutDuration" "LOW"
    printf "%-40s %4d %-10s\n" "PumpAndSettle without Duration:" "$pumpAndSettleWithoutDuration" "LOW"
    printf "%-40s %4d %-10s\n" "Expect on predicate:" "$widgetPredicate" "LOW"
    printf "%-40s %4d %-10s\n" "Expectation on Keys:"   "$expectKeysCount" "HIGH"
    printf "%-40s %4d %-10s\n" "Verify method calls:"   "$verifyArrowCount+verifyNeverArrowCount" "HIGH"
    printf "%-40s %4d %-10s\n" "Big Tests (>15 lines):"   "$testWidgetsLongCount+buildLongCount+testsLongCount" "HIGH"
    printf "%-40s %4d %-10s\n" "Files with 1 Test:"   "$singleTestWidgetsFilesCount" "CRITICAL"

    printf "\n\n%-40s %4d\n" "Total Issues Found:"   "$total"
  else
    echo "Oh My God! You've done good!"
  fi

}
