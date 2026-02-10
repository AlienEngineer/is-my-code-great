#!/usr/bin/env bats

load test_helper

setup() {
    export TEST_TEMP_DIR="$(mktemp -d)"
    export SCRIPT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    export DIR="$TEST_TEMP_DIR"
    export FRAMEWORK="dart"
    export CODE_FILE_PATTERN="*.dart"
    export TEST_FILE_PATTERN="*_test.dart"
    
    source "$SCRIPT_ROOT/lib/core/files.sh"
}

teardown() {
    rm -rf "$TEST_TEMP_DIR"
}

create_test_structure() {
    mkdir -p "$TEST_TEMP_DIR/lib"
    mkdir -p "$TEST_TEMP_DIR/test"
    
    touch "$TEST_TEMP_DIR/lib/code1.dart"
    touch "$TEST_TEMP_DIR/lib/code2.dart"
    touch "$TEST_TEMP_DIR/lib/code3.dart"
    
    touch "$TEST_TEMP_DIR/test/file1_test.dart"
    touch "$TEST_TEMP_DIR/test/file2_test.dart"
    touch "$TEST_TEMP_DIR/test/file3_test.dart"
}

@test "get_test_files: returns all test files" {
    create_test_structure
    
    # Count files directly without using run/output
    local count=0
    while IFS= read -r -d '' file; do
        count=$((count + 1))
    done < <(get_test_files)
    
    [ "$count" -eq 3 ]
}

@test "get_code_files: returns all code files" {
    create_test_structure
    
    # Count files directly without using run/output  
    local count=0
    while IFS= read -r -d '' file; do
        [[ "$file" == *.dart ]] && count=$((count + 1))
    done < <(get_code_files)
    
    [ "$count" -ge 3 ]
}
