declare -a SEVERITY COMMAND TITLE VALIDATION EXECUTION_TIME

function register_validation() {
    local check_name="$1"
    SEVERITY+=("$2")
    TITLE+=("$4")
    VALIDATION+=("$check_name")

    local start=$(date +%s%N)
    local command="$3"
    local result
    result=$(eval "$command") || {
      echo "Error executing command: $command" >&2
    }

    COMMAND+=("$result")

    elapsed=$((($(date +%s%N) - start) / 1000000))
    EXECUTION_TIME+=("$elapsed")

}

function get_validations() {
    printf "%s\n" "${VALIDATION[@]}"
}

function get_index() {
    local check_name="$1"
    for i in "${!VALIDATION[@]}"; do
        [[ "${VALIDATION[i]}" == "$check_name" ]] && echo "$i" && return
    done
    return 1
}

function get_severity() {
    local index
    index=$(get_index "$1")
    echo "${SEVERITY[$index]}"
}

function get_title() {
    local index
    index=$(get_index "$1")
    echo "${TITLE[$index]}"
}

function get_result() {
    local index
    index=$(get_index "$1")
    echo "${COMMAND[$index]}"
}

function get_execution_time() {
    local index
    index=$(get_index "$1")
    echo "${EXECUTION_TIME[$index]}"
}

function get_total_issues() {
    local total=0
    for result in "${COMMAND[@]}"; do
        total=$((total + result))
    done
    echo "$total"
}

function get_total_execution_time() {
    local total=0
    for time in "${EXECUTION_TIME[@]}"; do
        total=$((total + time))
    done
    echo "$total"
}

function print_validations_parseable() {
    get_validations | while read -r validation; do
        printf "%s=%d\n" "$validation" "$(get_result "$validation")"
    done
}

function print_validations() {
    local totalIssues=$(get_total_issues)
    printf "%-40s %10d\n\n" "Total Issues Found:" "$totalIssues"

    printf "%-40s %10s %-10s %15s\n" "Issues on Tests:" "#" "Severity" "Execution Time"
    get_validations | while read -r validation; do
        printf "%-40s %10d %-10s %15s\n" \
            "$(get_title "$validation")" \
            "$(get_result "$validation")" \
            "$(get_severity "$validation")" \
            "$(get_execution_time "$validation")ms"
    done
}
