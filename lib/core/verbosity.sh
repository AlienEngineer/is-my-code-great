   
function print_verbose() {
    local message="$1"
    if [ "$VERBOSE" = "1" ]; then
        echo "$message" >&2
    fi
}