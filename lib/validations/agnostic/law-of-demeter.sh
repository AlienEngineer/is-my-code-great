
#!/usr/bin/env bash

find_lines_that_violate_law_of_demeter_in_file() {
    local file="$1"
    grep -nE '\b[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*){3,}\b' "$file" \
     | grep -vE 'using ' \
     | grep -vE 'namespace ' \
     | grep -vE 'assembly\: ' \
     | while read -r line; do
        echo "$file:$line"
    done
}

my_custom_validaton() {
    local files=$(get_test_files_to_analyse)
    local count=0
    for file in $files; do
        while IFS= read -r match; do
            add_details "$match"
            count=$((count+1))
        done < <(find_lines_that_violate_law_of_demeter_in_file "$file")
    done
    echo "$count"
}

register_code_validation \
    "law-of-demeter" \
    "HIGH" \
    "my_custom_validaton" \
    "law-of-demeter (>2):"