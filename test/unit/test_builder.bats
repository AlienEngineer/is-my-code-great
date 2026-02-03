#!/usr/bin/env bats

# Tests for lib/core/builder.sh
# Focus: Validation registration and execution without eval

load test_helper

setup() {
    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    
    # Initialize variables that scripts expect
    export VERBOSE=false
    export DIR="$PROJECT_ROOT"
    
    # Initialize arrays that builder.sh expects
    declare -ga SEVERITY=()
    declare -ga COMMAND=()
    declare -ga TITLE=()
    declare -ga VALIDATION=()
    declare -ga EXECUTION_TIME=()
    declare -ga DETAILS=()
    declare -ga CATEGORY=()
    declare -gA VALIDATION_INDEX=()
    
    source "$PROJECT_ROOT/lib/core/verbosity.sh"
    source "$PROJECT_ROOT/lib/core/details_stub.sh"
    source "$PROJECT_ROOT/lib/core/builder.sh"
}

# Test helper: Define sample validation functions
sample_validation_passes() {
    echo "5"
}

sample_validation_fails() {
    return 1
}

# Helper functions for assertions (since we don't have bats-support)
assert_equal() {
    if [[ "$1" != "$2" ]]; then
        echo "Expected: $2"
        echo "Got: $1"
        return 1
    fi
}

assert_contains() {
    if [[ ! "$1" =~ $2 ]]; then
        echo "Expected '$1' to contain '$2'"
        return 1
    fi
}

# ==============================================================================
# Basic Registration Tests
# ==============================================================================

@test "register_test_validation: registers a test validation successfully" {
    register_test_validation "test-check" "HIGH" "sample_validation_passes" "Test Check Title"
    
    result=$(get_result "test-check")
    [ "$result" = "5" ]
}

@test "register_code_validation: registers a code validation successfully" {
    register_code_validation "code-check" "CRITICAL" "sample_validation_passes" "Code Check Title"
    
    result=$(get_result "code-check")
    [ "$result" = "5" ]
}

@test "register_test_validation: fails with missing parameters" {
    run register_test_validation "test-check" "HIGH" "" "Title"
    
    [ "$status" -ne 0 ]
}

@test "register_code_validation: fails with missing check_name" {
    run register_code_validation "" "CRITICAL" "sample_validation_passes" "Title"
    
    [ "$status" -ne 0 ]
}

# ==============================================================================
# Function Execution Tests (no eval)
# ==============================================================================

@test "register_validation: executes function directly without eval" {
    register_test_validation "direct-test" "HIGH" "sample_validation_passes" "Direct Execution Test"
    
    result=$(get_result "direct-test")
    [ "$result" = "5" ]
}

@test "register_validation: captures function execution failure" {
    run register_test_validation "fail-test" "HIGH" "sample_validation_fails" "Failing Test"
    
    [ "$status" -ne 0 ]
}

# ==============================================================================
# Input Sanitization Tests
# ==============================================================================

@test "register_validation: rejects function names with special characters" {
    run register_test_validation "bad-check" "HIGH" "rm -rf /" "Malicious Command"
    
    [ "$status" -ne 0 ]
}

@test "register_validation: rejects function names with semicolons" {
    run register_test_validation "bad-check" "HIGH" "echo foo; rm file" "Malicious Command"
    
    [ "$status" -ne 0 ]
}

@test "register_validation: rejects function names with pipes" {
    run register_test_validation "bad-check" "HIGH" "cat /etc/passwd | grep root" "Malicious Command"
    
    [ "$status" -ne 0 ]
}

@test "register_validation: accepts valid function names with underscores" {
    run register_test_validation "good-check" "HIGH" "sample_validation_passes" "Valid Function Name"
    
    [ "$status" -eq 0 ]
}

@test "register_validation: rejects invalid characters in function names" {
    run register_test_validation "bad-check" "HIGH" "sample-function" "Function with hyphen"
    
    # Hyphens are not valid in bash function names
    [ "$status" -ne 0 ]
}

# ==============================================================================
# Data Retrieval Tests
# ==============================================================================

@test "get_severity: returns correct severity for registered validation" {
    register_test_validation "severity-test" "CRITICAL" "sample_validation_passes" "Severity Test"
    
    result=$(get_severity "severity-test")
    [ "$result" = "CRITICAL" ]
}

@test "get_title: returns correct title for registered validation" {
    register_test_validation "title-test" "HIGH" "sample_validation_passes" "Custom Title"
    
    result=$(get_title "title-test")
    [ "$result" = "Custom Title" ]
}

@test "get_category: returns TESTS for test validation" {
    register_test_validation "category-test" "HIGH" "sample_validation_passes" "Category Test"
    
    result=$(get_category "category-test")
    [ "$result" = "TESTS" ]
}

@test "get_category: returns PRODUCTION for code validation" {
    register_code_validation "prod-test" "HIGH" "sample_validation_passes" "Production Test"
    
    result=$(get_category "prod-test")
    [ "$result" = "PRODUCTION" ]
}

@test "get_result: returns validation function result" {
    register_test_validation "result-test" "HIGH" "sample_validation_passes" "Result Test"
    
    result=$(get_result "result-test")
    [ "$result" = "5" ]
}

# ==============================================================================
# Multiple Validations Tests
# ==============================================================================

@test "register multiple validations and retrieve independently" {
    register_test_validation "multi-1" "HIGH" "sample_validation_passes" "Multi Test 1"
    register_test_validation "multi-2" "CRITICAL" "sample_validation_passes" "Multi Test 2"
    register_code_validation "multi-3" "LOW" "sample_validation_passes" "Multi Test 3"
    
    severity1=$(get_severity "multi-1")
    severity2=$(get_severity "multi-2")
    category3=$(get_category "multi-3")
    
    [ "$severity1" = "HIGH" ]
    [ "$severity2" = "CRITICAL" ]
    [ "$category3" = "PRODUCTION" ]
}

@test "get_test_validations: filters only test validations" {
    register_test_validation "test-1" "HIGH" "sample_validation_passes" "Test 1"
    register_code_validation "code-1" "HIGH" "sample_validation_passes" "Code 1"
    register_test_validation "test-2" "LOW" "sample_validation_passes" "Test 2"
    
    result=$(get_test_validations)
    
    [[ "$result" == *"test-1"* ]]
    [[ "$result" == *"test-2"* ]]
    [[ "$result" != *"code-1"* ]]
}

@test "get_production_validations: filters only code validations" {
    register_test_validation "test-1" "HIGH" "sample_validation_passes" "Test 1"
    register_code_validation "code-1" "HIGH" "sample_validation_passes" "Code 1"
    register_code_validation "code-2" "LOW" "sample_validation_passes" "Code 2"
    
    result=$(get_production_validations)
    
    [[ "$result" == *"code-1"* ]]
    [[ "$result" == *"code-2"* ]]
    [[ "$result" != *"test-1"* ]]
}

# ==============================================================================
# Edge Cases
# ==============================================================================

@test "register_validation: handles non-existent function gracefully" {
    run register_test_validation "nonexistent" "HIGH" "function_does_not_exist" "Nonexistent Function"
    
    [ "$status" -ne 0 ]
}

@test "get_total_issues: sums results from all validations" {
    register_test_validation "sum-1" "HIGH" "sample_validation_passes" "Sum Test 1"
    register_test_validation "sum-2" "HIGH" "sample_validation_passes" "Sum Test 2"
    
    total=$(get_total_issues)
    [ "$total" = "10" ]  # 5 + 5
}

@test "print_validations_parseable: outputs key=value format" {
    register_test_validation "parseable-1" "HIGH" "sample_validation_passes" "Parseable Test"
    
    run print_validations_parseable
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"parseable-1=5"* ]]
}

# ==============================================================================
# Performance & Timing Tests
# ==============================================================================

@test "register_validation: records execution time" {
    register_test_validation "timing-test" "HIGH" "sample_validation_passes" "Timing Test"
    
    time=$(get_execution_time "timing-test")
    
    # Should be a number (milliseconds)
    [[ "$time" =~ ^[0-9]+$ ]]
}

@test "get_total_execution_time: sums all execution times" {
    register_test_validation "time-1" "HIGH" "sample_validation_passes" "Time Test 1"
    register_test_validation "time-2" "HIGH" "sample_validation_passes" "Time Test 2"
    
    total_time=$(get_total_execution_time)
    
    # Should be a number and greater than 0
    [[ "$total_time" =~ ^[0-9]+$ ]]
    [ "$total_time" -gt 0 ]
}
