

count_expects_in_the_middle_in_file() {
  local file="$1"
  awk -v file="$file" '
        function reset_block(){ in_test=0; depth=0; pending=0 }
        BEGIN { reset_block() }

        /^[[:space:]]*(testWidgets|test|blocTest)([[:space:]]*<[^>]+>)?[[:space:]]*\(/ {
          in_test=1; depth=0; pending=0;
        }

        {
          if (in_test) {
            if ($0 ~ /expect[[:space:]]*\(/) {
              pending=1
            }

            if (pending &&
                ($0 ~ /await[ \t]+tester\./ ||
                 $0 ~ /(^|[[:space:]])tester\.(tap|enterText|pumpAndSettle|pump|drag|longPress|fling|scroll|press|sendKeyEvent)\(/)) {
              count++;
              # print file ":" NR ": action after expect → " $0
              pending=0
            }

            for (i=1;i<=length($0);i++) {
              ch=substr($0,i,1)
              if (ch=="{") depth++
              else if (ch=="}") depth--
            }

            if (depth<=0) {
              pending=0
              reset_block()
            }
          }
        }
        END { print count+0 }
      ' "$file"
}


get_files_to_analyse() {
  if [ "$LOCAL_RUN" = true ]; then
    find "$DIR" -type f -name '*test.dart'
  else
    get_git_files
  fi
}

get_count_expects_in_middle() {
  local total=0
  for file in $(get_files_to_analyse); do
    [[ -f "$file" ]] || continue
    total=$((total + $(count_expects_in_the_middle_in_file "$file")))
  done

  echo "$total"
}

register_validation \
    "expects-in-middle" \
    "LOW" \
    "get_count_expects_in_middle" \
    "Expects in the middle:"