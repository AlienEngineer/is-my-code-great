set -euo pipefail

declare -a SEVERITY=()
declare -a COMMAND=()
declare -a TITLE=()
declare -a VALIDATION=()
declare -a EXECUTION_TIME=()
declare -a DETAILS=()
declare -a CATEGORY=()
declare -gA VALIDATION_INDEX=()  # Maps check_name -> array index for O(1) lookup

# Validates that a function name contains only safe characters
# Returns 0 if valid, 1 if invalid
function _validate_function_name() {
    local func_name="$1"
    
    # Function names must contain only alphanumeric characters and underscores
    # No spaces, special characters, semicolons, pipes, redirects, etc.
    if [[ ! "$func_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Error: Invalid function name '$func_name'. Must contain only alphanumeric and underscore characters." >&2
        return 1
    fi
    
    return 0
}

# Verifies a function exists and is callable
# Returns 0 if function exists, 1 otherwise
function _verify_function_exists() {
    local func_name="$1"
    
    if ! declare -f "$func_name" > /dev/null; then
        echo "Error: Function '$func_name' does not exist or is not defined." >&2
        return 1
    fi
    
    return 0
}

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
    local command="$3"
    
    # Validate function name for security
    if ! _validate_function_name "$command"; then
        return 1
    fi
    
    # Verify function exists before registration
    if ! _verify_function_exists "$command"; then
        return 1
    fi
    
    # Store index for O(1) lookup (VALIDATION_INDEX maps name -> array index)
    VALIDATION_INDEX["$check_name"]="${#VALIDATION[@]}"
    
    SEVERITY+=("$2")
    TITLE+=("$4")
    CATEGORY+=("$5")
    VALIDATION+=("$check_name")

    print_verbose "[builder] Executing validation: $check_name"
    
    # Set context for details collection (CURRENT_CHECK_NAME used by add_details)
    export CURRENT_CHECK_NAME="$check_name"
    start_new_evaluation_details

    local start=$(date +%s%N)
    local result

    # Direct function invocation - no eval needed
    result=$("$command") || {
      echo "Error executing command: $command" >&2
      return 1
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
    local idx="${VALIDATION_INDEX[$check_name]:-}"
    [[ -z "$idx" ]] && return 1
    echo "$idx"
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
    # Direct array iteration instead of pipes to while loops (no subshells)
    local i
    for i in "${!VALIDATION[@]}"; do
        printf "%s=%s\n" "${VALIDATION[$i]}" "${COMMAND[$i]}"
    done
}