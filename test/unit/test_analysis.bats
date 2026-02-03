#!/usr/bin/env bats

load test_helper

setup() {
    export TEST_TEMP_DIR="$(mktemp -d)"
    export SCRIPT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    export DIR="$TEST_TEMP_DIR"
    export FRAMEWORK="dart"
    export PARSEABLE="0"
    export DETAILED="false"
    export VERBOSE="false"
    export LOCAL_RUN="true"
    export BASE_BRANCH=""
    export CURRENT_BRANCH="main"
}

teardown() {
    rm -rf "$TEST_TEMP_DIR"
}

# Basic integration tests to verify refactoring didn't break functionality

@test "run_analysis: fails if DIR does not exist" {
    source "$SCRIPT_ROOT/lib/analysis.sh"
    export DIR="/nonexistent/directory"
    
    run run_analysis
    assert_failure
    assert_output --partial "does not exist"
}

@test "run_analysis: succeeds with valid dart setup" {
    mkdir -p "$TEST_TEMP_DIR/test"
    echo "void main() { test('example', () {}); }" > "$TEST_TEMP_DIR/test/example_test.dart"
    
    source "$SCRIPT_ROOT/lib/analysis.sh"
    run run_analysis
    assert_success
}

@test "run_analysis: works with csharp framework" {
    export FRAMEWORK="csharp"
    mkdir -p "$TEST_TEMP_DIR/Tests"
    echo "using NUnit.Framework; [TestFixture] public class Tests { [Test] public void Example() {} }" > "$TEST_TEMP_DIR/Tests/ExampleTests.cs"
    
    source "$SCRIPT_ROOT/lib/analysis.sh"
    run run_analysis
    assert_success
}

@test "run_analysis: works with node framework" {
    export FRAMEWORK="node"
    mkdir -p "$TEST_TEMP_DIR/test"
    echo "describe('test', () => { it('works', () => {}); });" > "$TEST_TEMP_DIR/test/example.spec.ts"
    
    source "$SCRIPT_ROOT/lib/analysis.sh"
    run run_analysis
    assert_success
}

@test "run_analysis: fails with invalid framework" {
    export FRAMEWORK="nonexistent"
    mkdir -p "$TEST_TEMP_DIR/test"
    
    source "$SCRIPT_ROOT/lib/analysis.sh"
    run run_analysis
    assert_failure
}

@test "run_analysis: handles parseable output" {
    export PARSEABLE="1"
    mkdir -p "$TEST_TEMP_DIR/test"
    echo "void main() { test('example', () {}); }" > "$TEST_TEMP_DIR/test/example_test.dart"
    
    source "$SCRIPT_ROOT/lib/analysis.sh"
    run run_analysis
    assert_success
    refute_output --partial "Is my code great?"
}

@test "run_analysis: handles standard output" {
    export PARSEABLE="0"
    mkdir -p "$TEST_TEMP_DIR/test"
    echo "void main() { test('example', () {}); }" > "$TEST_TEMP_DIR/test/example_test.dart"
    
    source "$SCRIPT_ROOT/lib/analysis.sh"
    run run_analysis
    assert_success
    assert_output --partial "Is my code great?"
}

