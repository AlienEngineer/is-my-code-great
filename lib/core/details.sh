
declare -gA VALIDATION_DETAILS

function add_details() {
    local check_name="${CURRENT_CHECK_NAME:-unknown}"
    VALIDATION_DETAILS["$check_name"]+="${1}"$'\n'
}

function get_details(){
    local check_name="${CURRENT_CHECK_NAME:-unknown}"
    printf '%s' "${VALIDATION_DETAILS[$check_name]}"
}

function start_new_evaluation_details() {
    # Clear all details (called at start of analysis)
    VALIDATION_DETAILS=()
}
