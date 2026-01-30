#!/usr/bin/env bash

find_mock_declarations() {
  local files
  files=$(get_test_files) || return 1
  
  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    awk -v file="$file" '
    function reset_test_block(){ in_test=0; depth=0 }
    BEGIN { reset_test_block(); describe_depth=0 }

    {
      if ($0 ~ /describe\(/) {
        describe_depth=0
      }
    }

    {
      if ($0 ~ /it\(/ || $0 ~ /test\(/) {
        in_test=1; depth=0;
      }
    }

    {
      if (in_test) {
        for (i=1;i<=length($0);i++) {
          ch=substr($0,i,1)
          if (ch=="{") depth++
          else if (ch=="}") depth--
        }

        if (depth<=0) {
          reset_test_block()
        }
      }
      else {
        for (i=1;i<=length($0);i++) {
          ch=substr($0,i,1)
          if (ch=="{") describe_depth++
          else if (ch=="}") describe_depth--
        }

        if (describe_depth > 0 && $0 ~ /jest\.fn\(/) {
          printf("%s:%d: Mock field at describe block level\n", file, NR)
        }
      }
    }
    END { }
    ' "$file"
  done < <(printf '%s\n' "$files") | sort -u
}

function count_mock_declarations() {
  local total=0
  while read -r line; do
    add_details "$line"
    total=$(( total + 1 ))
  done < <(find_mock_declarations)

  echo "$total"
}

register_test_validation \
    "mock-abuse" \
    "HIGH" \
    "count_mock_declarations" \
    "Mock declarations at describe block level:"
