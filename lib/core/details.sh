
RESULT_DETAILS="$(mktemp)"
trap 'rm -f "$RESULT_DETAILS"' EXIT

function add_details() {
    echo "$1" >> "$RESULT_DETAILS"
}

function get_details(){
    cat "$RESULT_DETAILS"
}

function start_new_evaluation_details() {
    : > "$RESULT_DETAILS"
}
