declare -a SEVERITY COMMAND TITLE VALIDATION EXECUTION_TIME DETAILS CATEGORY

function register_test_validation() {
    local check_name="$1"
    local severity="$2"
    local command="$3"
    local title="$4"
    local category="TESTS"

    if [[ -z "$check_name" || -z "$severity" || -z "$command" || -z "$title" ]]; then
        echo "Error: Missing parameters for register_test_validation." >&2
        return 1
    fi

    register_validation "$check_name" "$severity" "$command" "$title" "$category"
}

function register_code_validation() {
    local check_name="$1"
    local severity="$2"
    local command="$3"
    local title="$4"
    local category="PRODUCTION"

    if [[ -z "$check_name" || -z "$severity" || -z "$command" || -z "$title" ]]; then
        echo "Error: Missing parameters for register_code_validation." >&2
        echo "Check name: $check_name, Severity: $severity, Command: $command, Title: $title" >&2
        echo "Category: $category" >&2
        echo "Please ensure all parameters are provided." >&2
        return 1
    fi

    register_validation "$check_name" "$severity" "$command" "$title" "$category"
}

function register_validation() {
    local check_name="$1"
    SEVERITY+=("$2")
    TITLE+=("$4")
    CATEGORY+=("$5")
    VALIDATION+=("$check_name")

    print_verbose "[builder] Executing validation: $check_name"
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

    print_verbose "[builder] Validation '$check_name' executed in $elapsed ms with result: $result"
}

function get_test_validations() {
    local validations=()
    for i in "${!VALIDATION[@]}"; do
        if [[ "${CATEGORY[$i]}" == "TESTS" ]]; then
            validations+=("${VALIDATION[$i]}")
        fi
    done
    printf "%s\n" "${validations[@]}"
}

function get_production_validations() {
    local validations=()
    for i in "${!VALIDATION[@]}"; do
        if [[ "${CATEGORY[$i]}" == "PRODUCTION" ]]; then
            validations+=("${VALIDATION[$i]}")
        fi
    done
    printf "%s\n" "${validations[@]}"
}

function get_category() {
    local index
    index=$(get_index "$1")
    echo "${CATEGORY[$index]}"
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

function print_validations_parseable() {
    get_production_validations | while read -r validation; do
        printf "%s=%d\n" "$validation" "$(get_result "$validation")"
    done
    get_test_validations | while read -r validation; do
        printf "%s=%d\n" "$validation" "$(get_result "$validation")"
    done
}