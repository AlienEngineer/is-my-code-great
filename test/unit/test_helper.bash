#!/usr/bin/env bash
# Test helper functions for bats-core tests

# Simple assert functions (no external dependencies needed)
assert_success() {
    if [ "$status" -ne 0 ]; then
        echo "Expected success (status 0), got: $status"
        echo "Output: $output"
        return 1
    fi
}

assert_failure() {
    if [ "$status" -eq 0 ]; then
        echo "Expected failure (non-zero status), got: $status"
        echo "Output: $output"
        return 1
    fi
}

assert_output() {
    if [ "$1" = "--partial" ]; then
        local expected="$2"
        if [[ ! "$output" =~ $expected ]]; then
            echo "Expected output to contain: $expected"
            echo "Actual output: $output"
            return 1
        fi
    else
        local expected="$1"
        if [ "$output" != "$expected" ]; then
            echo "Expected output: $expected"
            echo "Actual output: $output"
            return 1
        fi
    fi
}

refute_output() {
    if [ "$1" = "--partial" ]; then
        local unexpected="$2"
        if [[ "$output" =~ $unexpected ]]; then
            echo "Expected output to NOT contain: $unexpected"
            echo "Actual output: $output"
            return 1
        fi
    else
        local unexpected="$1"
        if [ "$output" = "$unexpected" ]; then
            echo "Expected output to NOT be: $unexpected"
            echo "Actual output: $output"
            return 1
        fi
    fi
}

# Helper: Assert output contains string
assert_output_contains() {
    local expected="$1"
    if [[ ! "$output" =~ $expected ]]; then
        echo "Expected output to contain: $expected"
        echo "Actual output: $output"
        return 1
    fi
}

# Helper: Assert output does not contain string
assert_output_not_contains() {
    local unexpected="$1"
    if [[ "$output" =~ $unexpected ]]; then
        echo "Expected output to NOT contain: $unexpected"
        echo "Actual output: $output"
        return 1
    fi
}

# Helper: Create mock file with content
create_mock_file() {
    local filepath="$1"
    local content="$2"
    local dir
    dir="$(dirname "$filepath")"
    mkdir -p "$dir"
    echo "$content" > "$filepath"
}

# Helper: Mock function for testing
mock_function() {
    local func_name="$1"
    local mock_output="$2"
    eval "${func_name}() { echo '${mock_output}'; }"
    export -f "$func_name"
}

# Helper: Capture stderr
run_capture_stderr() {
    local stderr_file="$TEST_TEMP_DIR/stderr.txt"
    run bash -c "$* 2>$stderr_file"
    stderr="$(<"$stderr_file")"
    export stderr
}

# Helper: Assert file exists
assert_file_exists() {
    local filepath="$1"
    if [[ ! -f "$filepath" ]]; then
        echo "Expected file to exist: $filepath"
        return 1
    fi
}

# Helper: Assert file does not exist
assert_file_not_exists() {
    local filepath="$1"
    if [[ -f "$filepath" ]]; then
        echo "Expected file to NOT exist: $filepath"
        return 1
    fi
}

# Helper: Assert exit status equals expected
assert_exit_status() {
    local expected="$1"
    if [[ "$status" -ne "$expected" ]]; then
        echo "Expected exit status: $expected"
        echo "Actual exit status: $status"
        return 1
    fi
}
