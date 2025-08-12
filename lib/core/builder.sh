#!]

declare -a SEVERITY COMMAND TITLE VALIDATION EXECUTION_TIME DETAILS

function register_validation() {
    local check_name="$1"
    SEVERITY+=("$2")
    TITLE+=("$4")
    VALIDATION+=("$check_name")

    start_new_evaluation_details

    local start=$(date +%s%N)
    local command="$3"
    local result
    result=$(eval "$command") || {
      echo "Error executing command: $command" >&2
    }

    local details
    details=$(get_details)

    DETAILS+=("$details")

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

function get_execution_details() {
    local index
    index=$(get_index "$1")
    echo "${DETAILS[$index]}"
}

function get_total_execution_time() {
    local total=0
    for time in "${EXECUTION_TIME[@]}"; do
        total=$((total + time))
    done
    echo "$total"
}
