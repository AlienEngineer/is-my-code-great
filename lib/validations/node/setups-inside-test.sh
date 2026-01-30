#!/usr/bin/env bash

find_setups_in_tests() {
  local files
  files=$(get_test_files) || return 1
  
  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    awk -v file="$file" '
    function reset_block(){ in_test=0; depth=0 }
    BEGIN { reset_block() }

    {
      if ($0 ~ /it\(/ || $0 ~ /test\(/) {
        in_test=1; depth=0;
      }
    }

    {
      if (in_test) {
        if ($0 ~ /mockReturnValue\(|mockResolvedValue\(|mockRejectedValue\(|jest\.fn\(/) {
          printf("%s:%d: Mock setup inside test method\n", file, NR)
        }

        for (i=1;i<=length($0);i++) {
          ch=substr($0,i,1)
          if (ch=="{") depth++
          else if (ch=="}") depth--
        }

        if (depth<=0) {
          reset_block()
        }
      }
    }
    END { }
    ' "$file"
  done < <(printf '%s\n' "$files") | sort -u
}

function count_setups_in_tests() {
  local total=0
  while read -r line; do
    add_details "$line"
    total=$(( total + 1 ))
  done < <(find_setups_in_tests)

  echo "$total"
}

register_test_validation \
    "setups-inside-test" \
    "HIGH" \
    "count_setups_in_tests" \
    "Mock setup calls inside test methods:"
