#!/usr/bin/env bats
# Unit tests for lib/core/errors.sh
# These tests are written BEFORE implementing the actual error handling functions
# Following TDD: Red -> Green -> Refactor

load test_helper

setup() {
    # Create temporary directory for test fixtures
    TEST_TEMP_DIR="$(mktemp -d)"
    
    # Path to the errors.sh file we'll create
    ERRORS_LIB="$BATS_TEST_DIRNAME/../../lib/core/errors.sh"
}

teardown() {
    # Clean up temporary directory
    if [[ -d "${TEST_TEMP_DIR:-}" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Test: die() function exists and is callable
@test "die() function should exist" {
    # This will fail until we implement errors.sh
    run bash -c "source '$ERRORS_LIB' && declare -f die"
    assert_exit_status 0
}

# Test: die() outputs error message to stderr
@test "die() should output error message to stderr" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_die.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"
die "Test error message"
EOF
    chmod +x "$test_script"
    
    run bash -c "$test_script 2>&1 1>/dev/null"
    assert_output_contains "Test error message"
}

# Test: die() exits with status 1
@test "die() should exit with status 1" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_die_exit.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"
die "Fatal error"
echo "This should not execute"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    assert_exit_status 1
    assert_output_not_contains "This should not execute"
}

# Test: die() calls cleanup if CLEANUP_FUNC is set
@test "die() should call cleanup function if CLEANUP_FUNC is set" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_die_cleanup.sh"
    local cleanup_marker="$TEST_TEMP_DIR/cleanup_called"
    
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"

cleanup_test() {
    echo "cleanup" > "$cleanup_marker"
}

CLEANUP_FUNC=cleanup_test
die "Error with cleanup"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    assert_exit_status 1
    assert_file_exists "$cleanup_marker"
    [[ "$(cat "$cleanup_marker")" == "cleanup" ]]
}

# Test: warn() function exists
@test "warn() function should exist" {
    skip "Waiting for errors.sh implementation"
    
    run bash -c "source '$ERRORS_LIB' && declare -f warn"
    assert_exit_status 0
}

# Test: warn() outputs to stderr but doesn't exit
@test "warn() should output to stderr without exiting" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_warn.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"
warn "Warning message"
echo "continuing"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    assert_exit_status 0
    assert_output_contains "continuing"
}

# Test: debug() function exists
@test "debug() function should exist" {
    skip "Waiting for errors.sh implementation"
    
    run bash -c "source '$ERRORS_LIB' && declare -f debug"
    assert_exit_status 0
}

# Test: debug() only outputs when VERBOSE is set
@test "debug() should only output when VERBOSE is set" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_debug.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"

# Test without VERBOSE
debug "Debug message 1"

# Test with VERBOSE
export VERBOSE=true
debug "Debug message 2"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    assert_exit_status 0
    assert_output_not_contains "Debug message 1"
    assert_output_contains "Debug message 2"
}

# Test: setup_error_traps() function exists
@test "setup_error_traps() function should exist" {
    skip "Waiting for errors.sh implementation"
    
    run bash -c "source '$ERRORS_LIB' && declare -f setup_error_traps"
    assert_exit_status 0
}

# Test: ERR trap catches command failures
@test "ERR trap should catch command failures" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_err_trap.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"
setup_error_traps

false  # This should trigger ERR trap
EOF
    chmod +x "$test_script"
    
    run "$test_script" 2>&1
    assert_exit_status 1
    # Should contain error information
    [[ "$output" =~ (ERR|error|failed) ]]
}

# Test: INT trap handles Ctrl+C gracefully
@test "INT trap should handle interruption gracefully" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_int_trap.sh"
    local cleanup_marker="$TEST_TEMP_DIR/int_cleanup"
    
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"

cleanup_int() {
    echo "interrupted" > "$cleanup_marker"
}

CLEANUP_FUNC=cleanup_int
setup_error_traps

# Simulate receiving SIGINT
kill -INT \$\$
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    # Should handle INT and call cleanup
    assert_file_exists "$cleanup_marker"
}

# Test: EXIT trap runs cleanup on normal exit
@test "EXIT trap should run cleanup on normal exit" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_exit_trap.sh"
    local cleanup_marker="$TEST_TEMP_DIR/exit_cleanup"
    
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"

cleanup_exit() {
    echo "exited" > "$cleanup_marker"
}

CLEANUP_FUNC=cleanup_exit
setup_error_traps

echo "normal exit"
exit 0
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    assert_exit_status 0
    assert_file_exists "$cleanup_marker"
    [[ "$(cat "$cleanup_marker")" == "exited" ]]
}

# Test: Multiple trap handlers don't conflict
@test "multiple traps should not conflict" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_multi_trap.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"

call_count=0
cleanup_multi() {
    call_count=$((call_count + 1))
    echo "Cleanup called: $call_count" >&2
}

CLEANUP_FUNC=cleanup_multi
setup_error_traps

# Normal exit should call cleanup only once
exit 0
EOF
    chmod +x "$test_script"
    
    run "$test_script" 2>&1
    assert_exit_status 0
    # Cleanup should be called exactly once
    [[ $(grep -c "Cleanup called: 1" <<< "$output") -eq 1 ]]
    [[ ! "$output" =~ "Cleanup called: 2" ]]
}

# Test: Error messages include script name and line number
@test "die() should include script context (file:line)" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_context.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"

die "Context error"
EOF
    chmod +x "$test_script"
    
    run "$test_script" 2>&1
    assert_exit_status 1
    # Should contain filename and line number
    [[ "$output" =~ test_context\.sh ]]
}

# Test: Nested errors don't cause infinite loops
@test "nested errors should not cause infinite loops" {
    skip "Waiting for errors.sh implementation"
    
    local test_script="$TEST_TEMP_DIR/test_nested.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "lib/core/errors.sh"

cleanup_fail() {
    # Cleanup that might fail
    false
}

CLEANUP_FUNC=cleanup_fail
setup_error_traps

die "Original error"
EOF
    chmod +x "$test_script"
    
    # Script should still exit, not hang
    run timeout 5s "$test_script" 2>&1
    # Should exit (not timeout)
    [[ $status -ne 124 ]]  # 124 is timeout's exit code
}
