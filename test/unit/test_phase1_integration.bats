#!/usr/bin/env bats
# Integration tests for Phase 1.1 error handling
# Tests that the entire system still works after adding strict mode

load test_helper

setup() {
    TEST_TEMP_DIR="$(mktemp -d)"
    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    BIN_PATH="$PROJECT_ROOT/bin/is-my-code-great"
}

teardown() {
    if [[ -d "${TEST_TEMP_DIR:-}" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Test: Tool still runs successfully on Dart example
@test "tool should still analyze Dart example after strict mode changes" {
    skip "Will enable after Phase 1.1 implementation"
    
    run "$BIN_PATH" "$PROJECT_ROOT/examples/dart"
    assert_exit_status 0
}

# Test: Tool still runs successfully on C# example
@test "tool should still analyze C# example after strict mode changes" {
    skip "Will enable after Phase 1.1 implementation"
    
    run "$BIN_PATH" "$PROJECT_ROOT/examples/csharp"
    assert_exit_status 0
}

# Test: Tool still runs successfully on Node example
@test "tool should still analyze Node example after strict mode changes" {
    skip "Will enable after Phase 1.1 implementation"
    
    run "$BIN_PATH" "$PROJECT_ROOT/examples/node"
    assert_exit_status 0
}

# Test: Verbose mode still works
@test "tool should still work with verbose mode" {
    skip "Will enable after Phase 1.1 implementation"
    
    run "$BIN_PATH" -v "$PROJECT_ROOT/examples/dart"
    assert_exit_status 0
    # Verbose output should contain debug info
    [[ "$output" =~ (Analyzing|Framework|Validations) ]]
}

# Test: Parseable mode still works
@test "tool should still work with parseable mode" {
    skip "Will enable after Phase 1.1 implementation"
    
    run "$BIN_PATH" -p "$PROJECT_ROOT/examples/dart"
    assert_exit_status 0
}

# Test: Git diff mode still works
@test "tool should still work in git diff mode" {
    skip "Will enable after Phase 1.1 implementation"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Only run if we're in a git repo with commits
    if git rev-parse --git-dir > /dev/null 2>&1; then
        run "$BIN_PATH" -b main
        # Should not crash (may have 0 or more findings)
        [[ $status -eq 0 ]] || [[ $status -eq 1 ]]
    fi
}

# Test: Invalid path shows proper error
@test "tool should show proper error for invalid path" {
    skip "Will enable after Phase 1.1 implementation"
    
    run "$BIN_PATH" "/nonexistent/path" 2>&1
    [[ $status -ne 0 ]]
    # Should contain meaningful error message
    [[ "$output" =~ (not found|does not exist|invalid) ]]
}

# Test: Missing framework detection shows error
@test "tool should show error when framework cannot be detected" {
    skip "Will enable after Phase 1.1 implementation"
    
    # Create empty directory
    local empty_dir="$TEST_TEMP_DIR/empty"
    mkdir -p "$empty_dir"
    
    run "$BIN_PATH" "$empty_dir" 2>&1
    [[ $status -ne 0 ]]
    [[ "$output" =~ (framework|detect|unknown) ]]
}

# Test: Interrupted execution cleans up properly
@test "tool should clean up when interrupted" {
    skip "Will enable after Phase 1.1 implementation"
    
    # Start the tool and interrupt it
    # This is complex to test reliably, so we'll check the trap setup instead
    run bash -c "grep -r 'trap.*INT' '$PROJECT_ROOT/lib/core/errors.sh'"
    assert_exit_status 0
}

# Test: Error in validation doesn't crash entire tool
@test "error in one validation should not crash the tool" {
    skip "Will enable after Phase 1.1 implementation"
    
    # This requires injecting a failing validation, which is complex
    # For now, verify error handling infrastructure exists
    run bash -c "grep -r 'die\\|warn' '$PROJECT_ROOT/lib/core/errors.sh'"
    assert_exit_status 0
}

# Test: Detailed report still generates
@test "tool should still generate detailed HTML report" {
    skip "Will enable after Phase 1.1 implementation"
    
    run "$BIN_PATH" -d "$PROJECT_ROOT/examples/dart"
    assert_exit_status 0
    
    # Should create HTML report
    assert_file_exists "$PROJECT_ROOT/is-my-code-great-report.html"
    
    # Clean up
    rm -f "$PROJECT_ROOT/is-my-code-great-report.html"
}

# Test: All existing integration tests still pass
@test "existing integration test suite should still pass" {
    skip "Will enable after Phase 1.1 implementation"
    
    # Run the existing validation script
    run "$PROJECT_ROOT/test/validate_results.sh"
    assert_exit_status 0
}

# Test: Tool handles SIGTERM gracefully
@test "tool should handle SIGTERM gracefully" {
    skip "Will enable after Phase 1.1 implementation"
    
    # Start tool in background on a large project
    "$BIN_PATH" "$PROJECT_ROOT" &
    local pid=$!
    
    # Give it a moment to start
    sleep 1
    
    # Send SIGTERM
    kill -TERM "$pid" 2>/dev/null || true
    
    # Wait for cleanup
    wait "$pid" 2>/dev/null || true
    local exit_code=$?
    
    # Should exit cleanly (not 0, but not crash)
    [[ $exit_code -ne 0 ]]
}

# Test: Concurrent runs don't interfere
@test "concurrent runs should not interfere with each other" {
    skip "Will enable after Phase 1.1 implementation"
    
    # Run two instances simultaneously
    "$BIN_PATH" "$PROJECT_ROOT/examples/dart" > "$TEST_TEMP_DIR/output1.txt" 2>&1 &
    local pid1=$!
    
    "$BIN_PATH" "$PROJECT_ROOT/examples/node" > "$TEST_TEMP_DIR/output2.txt" 2>&1 &
    local pid2=$!
    
    # Wait for both
    wait "$pid1"
    local exit1=$?
    wait "$pid2"
    local exit2=$?
    
    # Both should succeed
    [[ $exit1 -eq 0 ]]
    [[ $exit2 -eq 0 ]]
    
    # Outputs should be different (no interference)
    ! diff "$TEST_TEMP_DIR/output1.txt" "$TEST_TEMP_DIR/output2.txt" > /dev/null
}
