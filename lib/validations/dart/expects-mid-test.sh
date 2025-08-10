

# Counts "expects in the middle" (NOT the final expect) on changed *_test.dart files
get_count_expects_in_middle_git() {
  local files
  files="$(get_git_files)"

  local total=0
  local IFS=$'\n'
  for file in $files; do
    [[ -f "$file" ]] || continue
    local abs_file="${repo_root}/${file}"
    local c
    c=$(
      awk -v file="$abs_file" '
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
      ' "$abs_file"
    )

    total=$((total + c))
  done
  unset IFS

  echo "$total"
}

register_validation \
    "expects-in-middle" \
    "LOW" \
    "get_count_expects_in_middle_git" \
    "Expects in the middle:"