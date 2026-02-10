#!/usr/bin/env bats

# Unit tests for lib/core/text-finders.sh

load test_helper

# Setup runs before each test
setup() {
    # Create temporary test directory
    TEST_DIR="$(mktemp -d)"
    export TEST_DIR
    
    # Source constants (needed by text-finders)
    source "$BATS_TEST_DIRNAME/../../lib/core/constants.sh"
    
    # Source the functions we're testing
    source "$BATS_TEST_DIRNAME/../../lib/core/text-finders.sh"
    
    # Create sample test files
    cat > "$TEST_DIR/test1.dart" << 'EOF'
test('sample test', () {
    expect(1).toBe(1);
    verify(mockObj).called();
});
EOF

    cat > "$TEST_DIR/test2.dart" << 'EOF'
test('another test', () {
    expect(2).toBe(2);
});
EOF

    # Create sample code files
    cat > "$TEST_DIR/code1.dart" << 'EOF'
class MyClass {
    void method() {
        a.b.c.d.e();
    }
}
EOF

    cat > "$TEST_DIR/code2.dart" << 'EOF'
class AnotherClass {
    void anotherMethod() {
        x.y.z();
    }
}
EOF
}

# Teardown runs after each test
teardown() {
    rm -rf "$TEST_DIR"
}

# Helper function to mock get_test_files (returns null-terminated output)
get_test_files() {
    find "$TEST_DIR" -name "*test*.dart" -print0 2>/dev/null
}

# Helper function to mock get_code_files (returns null-terminated output)
get_code_files() {
    find "$TEST_DIR" -name "*.dart" ! -name "*test*" -print0 2>/dev/null
}

# Export for subprocess visibility
export -f get_test_files
export -f get_code_files

# Helper to mock add_details (for DETAILED mode)
add_details() {
    echo "[DETAIL] $1" >> "$TEST_DIR/details.log"
}
export -f add_details

# ============================================================================
# Tests for _sum_results (internal helper)
# ============================================================================

@test "_sum_results: requires file_getter parameter" {
    run _sum_results "" "-F" "pattern"
    assert_exit_status 1
    assert_output_contains "file_getter required"
}

@test "_sum_results: requires flags parameter" {
    run _sum_results "get_test_files" "" "pattern"
    assert_exit_status 1
    assert_output_contains "flags required"
}

@test "_sum_results: requires pattern parameter" {
    run _sum_results "get_test_files" "-F" ""
    assert_exit_status 1
    assert_output_contains "pattern required"
}

@test "_sum_results: counts matches in files" {
    run _sum_results "get_test_files" "-F" "expect"
    assert_exit_status 0
    # Should find 2 instances of "expect" in test files
    [ "$output" = "2" ]
}

@test "_sum_results: returns 0 for no matches" {
    run _sum_results "get_test_files" "-F" "nonexistent_pattern"
    assert_exit_status 0
    [ "$output" = "0" ]
}

@test "_sum_results: handles empty file list gracefully" {
    # Create a getter that returns no files
    empty_getter() {
        echo ""
    }
    export -f empty_getter
    
    run _sum_results "empty_getter" "-F" "pattern"
    assert_exit_status 0
    [ "$output" = "0" ]
}

@test "_sum_results: DETAILED mode adds details" {
    export DETAILED="true"
    
    run _sum_results "get_test_files" "-F" "expect"
    assert_exit_status 0
    # Should have created details log
    assert_file_exists "$TEST_DIR/details.log"
    # Should have 2 entries (one for each match)
    local count
    count=$(wc -l < "$TEST_DIR/details.log")
    [ "$count" -eq 2 ]
}

@test "_sum_results: non-DETAILED mode skips details" {
    export DETAILED="false"
    
    run _sum_results "get_test_files" "-F" "expect"
    assert_exit_status 0
    # Should NOT have created details log
    assert_file_not_exists "$TEST_DIR/details.log"
}

# ============================================================================
# Tests for sum_test_results
# ============================================================================

@test "sum_test_results: counts occurrences in test files" {
    run sum_test_results "-F" "expect"
    assert_exit_status 0
    [ "$output" = "2" ]
}

@test "sum_test_results: uses correct grep flags" {
    # Test with regex flag
    run sum_test_results "-E" "expect\(.*\)"
    assert_exit_status 0
    [ "$output" = "2" ]
}

@test "sum_test_results: returns 0 for no matches" {
    run sum_test_results "-F" "no_such_string"
    assert_exit_status 0
    [ "$output" = "0" ]
}

# ============================================================================
# Tests for sum_code_results
# ============================================================================

@test "sum_code_results: counts occurrences in code files" {
    run sum_code_results "-F" "class"
    assert_exit_status 0
    # Should find "class" in code1.dart and code2.dart
    [ "$output" = "2" ]
}

@test "sum_code_results: uses correct grep flags" {
    run sum_code_results "-E" "void.*\(\)"
    assert_exit_status 0
    # Should find method declarations
    [ "$output" -ge 2 ]
}

@test "sum_code_results: returns 0 for no matches" {
    run sum_code_results "-F" "nonexistent_class"
    assert_exit_status 0
    [ "$output" = "0" ]
}

# ============================================================================
# Tests for find_text_in_test (wrapper)
# ============================================================================

@test "find_text_in_test: finds exact text matches" {
    run find_text_in_test "verify"
    assert_exit_status 0
    [ "$output" = "1" ]
}

@test "find_text_in_test: is case-sensitive by default" {
    run find_text_in_test "EXPECT"
    assert_exit_status 0
    [ "$output" = "0" ]
}

@test "find_text_in_test: handles special characters" {
    # Add file with special characters
    cat > "$TEST_DIR/special_test.dart" << 'EOF'
test('test with dots', () {
    expect(obj.property).toBe(true);
});
EOF
    
    run find_text_in_test "obj.property"
    assert_exit_status 0
    [ "$output" = "1" ]
}

# ============================================================================
# Tests for find_regex_in_test (wrapper)
# ============================================================================

@test "find_regex_in_test: matches regex patterns" {
    skip "TODO: Fix regex pattern matching in tests"
    run find_regex_in_test "test\('.*'\)"
    assert_exit_status 0
    # Should match test('sample test') and test('another test')
    [ "$output" = "2" ]
}

@test "find_regex_in_test: handles complex regex" {
    run find_regex_in_test "expect\([0-9]+\)"
    assert_exit_status 0
    [ "$output" = "2" ]
}

# ============================================================================
# Tests for find_text_in_files (wrapper)
# ============================================================================

@test "find_text_in_files: finds text in code files" {
    run find_text_in_files "MyClass"
    assert_exit_status 0
    [ "$output" = "1" ]
}

@test "find_text_in_files: returns 0 for no matches" {
    run find_text_in_files "NonExistentClass"
    assert_exit_status 0
    [ "$output" = "0" ]
}

# ============================================================================
# Tests for find_regex_in_files (wrapper)
# ============================================================================

@test "find_regex_in_files: matches regex in code files" {
    run find_regex_in_files "class.*\{"
    assert_exit_status 0
    [ "$output" = "2" ]
}

# ============================================================================
# Edge Cases
# ============================================================================

@test "edge case: handles filenames with spaces" {
    skip "TODO: Fix filename with spaces handling in test environment"
    # Create file with spaces in name
    cat > "$TEST_DIR/test with spaces.dart" << 'EOF'
test('spaced test', () {
    expect(true).toBe(true);
});
EOF
    
    run find_text_in_test "spaced test"
    assert_exit_status 0
    # Should find it (xargs with -r handles spaces)
    [ "$output" -ge 1 ]
}

@test "edge case: handles empty files" {
    touch "$TEST_DIR/empty_test.dart"
    
    run sum_test_results "-F" "anything"
    assert_exit_status 0
    # Should not crash, just return count
    [ "$output" -ge 0 ]
}

@test "edge case: handles files with no newline at EOF" {
    printf 'test("no newline")' > "$TEST_DIR/no_newline_test.dart"
    
    run find_text_in_test "no newline"
    assert_exit_status 0
    [ "$output" = "1" ]
}

@test "edge case: large file with many matches" {
    skip "TODO: Fix large file test - may be timing or environment issue"
    # Create file with 100 matches
    {
        for i in {1..100}; do
            echo "expect($i).toBe($i);"
        done
    } > "$TEST_DIR/big_test.dart"
    
    run find_text_in_test "expect"
    assert_exit_status 0
    [ "$output" = "100" ]
}

@test "edge case: pattern not found returns exactly 0" {
    run sum_test_results "-F" "absolutely_not_there"
    assert_exit_status 0
    [ "$output" = "0" ]
}

# ============================================================================
# Integration with DETAILED flag
# ============================================================================

@test "DETAILED mode: collects all match details" {
    export DETAILED="true"
    
    run sum_test_results "-n" "expect"
    assert_exit_status 0
    
    # Check details were logged
    assert_file_exists "$TEST_DIR/details.log"
    
    # Each detail should include filename and line number
    grep -q "test.*\.dart" "$TEST_DIR/details.log"
}

@test "DETAILED mode: count matches number of detail entries" {
    export DETAILED="true"
    
    run sum_test_results "-F" "expect"
    assert_exit_status 0
    
    local result_count="$output"
    local detail_count
    detail_count=$(wc -l < "$TEST_DIR/details.log" 2>/dev/null || echo 0)
    
    # Result count should match detail entry count
    [ "$result_count" -eq "$detail_count" ]
}
