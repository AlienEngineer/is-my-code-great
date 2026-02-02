#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Auto-detect available frameworks
_get_available_frameworks() {
    local test_dir="$PROJECT_ROOT/test"
    for dir in "$test_dir"/*; do
        if [ -d "$dir" ] && [ -f "$dir/expected_results.sh" ]; then
            basename "$dir"
        fi
    done | sort
}

# Validate framework exists
_is_valid_framework() {
    local framework="$1"
    _get_available_frameworks | grep -q "^$framework$"
}

# Helper: Get expected count for a key
_get_expected_count() {
    local key="$1"
    echo "$EXPECTED_RESULTS" | grep "^$key:" | cut -d: -f2 | tr -d ' ' || echo ""
}

# Helper: Get actual count for a key
_get_actual_count() {
    local key="$1"
    echo "$ACTUAL_RESULTS" | grep "^$key=" | cut -d= -f2 | tr -d ' ' || echo ""
}

# Run tests for a single framework
_run_framework_tests() {
    local language="$1"
    local expected_results_file="$PROJECT_ROOT/test/$language/expected_results.sh"
    local examples_dir="$PROJECT_ROOT/examples/$language"

    if [ ! -f "$expected_results_file" ]; then
        echo "Error: Expected results file not found: $expected_results_file"
        return 1
    fi

    if [ ! -d "$examples_dir" ]; then
        echo "Error: Examples directory not found: $examples_dir"
        return 1
    fi

    (
        source "$expected_results_file"

        cd "$examples_dir"
        ACTUAL_RESULTS=$("$PROJECT_ROOT/bin/is-my-code-great" -p 2>/dev/null || true)

        local exit_code=0

        while IFS=: read -r expected_key expected_count; do
            expected_key=$(echo "$expected_key" | tr -d ' ')
            expected_count=$(echo "$expected_count" | tr -d ' ')

            actual_count=$(_get_actual_count "$expected_key")
            [ -z "$actual_count" ] && actual_count="0"

            if [ "$actual_count" -eq "$expected_count" ]; then
                echo "  ✅ PASS: $expected_key (expected: $expected_count, actual: $actual_count)"
            else
                echo "  ❌ FAIL: $expected_key (expected: $expected_count, actual: $actual_count)"
                exit_code=1
            fi
        done < <(echo "$EXPECTED_RESULTS" | grep ":")

        while IFS= read -r line; do
            actual_key=$(echo "$line" | cut -d= -f1 | tr -d ' ')
            actual_value=$(echo "$line" | cut -d= -f2 | tr -d ' ')

            expected_count=$(_get_expected_count "$actual_key")

            if [ -z "$expected_count" ]; then
                echo "  ⚠ WARNING: Unexpected result found: $actual_key=$actual_value"
            fi
        done < <(echo "$ACTUAL_RESULTS" | grep "=")

        return "$exit_code"
    )
}

# Run unit tests
_run_unit_tests() {
    local unit_test_dir="$PROJECT_ROOT/test/unit"
    
    # Check if bats is available
    if ! command -v bats &> /dev/null; then
        echo "  ⚠ WARNING: bats-core not installed, skipping unit tests"
        echo "  Install with: brew install bats-core"
        return 2  # Special code for skipped
    fi
    
    # Check if unit tests exist
    if [ ! -d "$unit_test_dir" ] || [ -z "$(ls -A "$unit_test_dir"/*.bats 2>/dev/null)" ]; then
        echo "  ℹ No unit tests found"
        return 2  # Special code for skipped
    fi
    
    local test_failed=0
    local test_count=0
    
    for test_file in "$unit_test_dir"/*.bats; do
        [ -f "$test_file" ] || continue
        test_name=$(basename "$test_file" .bats)
        test_count=$((test_count + 1))
        
        if bats "$test_file" > /dev/null 2>&1; then
            echo "  ✅ PASS: $test_name"
        else
            echo "  ❌ FAIL: $test_name"
            test_failed=1
        fi
    done
    
    return "$test_failed"
}

# Main logic
if [ $# -eq 0 ]; then
    # Run all tests (unit + integration)
    echo "Running all tests..."
    echo "=========================================="
    echo ""
    
    # Run unit tests first
    echo "Unit Tests"
    echo "----------"
    unit_exit_code=0
    if _run_unit_tests; then
        echo "✅ Unit tests PASSED"
    elif [ $? -eq 2 ]; then
        echo "⊘ Unit tests SKIPPED"
    else
        echo "❌ Unit tests FAILED"
        unit_exit_code=1
    fi
    
    echo ""
    echo "Integration Tests"
    echo "-----------------"
    
    frameworks_passed=0
    frameworks_failed=0
    overall_exit_code="$unit_exit_code"

    for framework in $(_get_available_frameworks); do
        echo ""
        echo "Validating $framework results..."
        echo "================================"
        
        if _run_framework_tests "$framework"; then
            echo "✅ $framework PASSED"
            frameworks_passed=$((frameworks_passed + 1))
        else
            echo "❌ $framework FAILED"
            frameworks_failed=$((frameworks_failed + 1))
            overall_exit_code=1
        fi
    done

    echo ""
    echo "=========================================="
    echo "Summary:"
    echo "  Unit tests: $([ "$unit_exit_code" -eq 0 ] && echo "PASSED" || echo "FAILED")"
    echo "  Integration: $frameworks_passed passed, $frameworks_failed failed"
    echo "=========================================="
    exit "$overall_exit_code"
else
    # Run specific framework or unit tests
    test_type="$1"
    
    if [ "$test_type" == "unit" ]; then
        echo "Running unit tests..."
        echo "====================="
        _run_unit_tests
        exit $?
    fi
    
    language="$test_type"
    
    if ! _is_valid_framework "$language"; then
        echo "Error: Unknown framework '$language'"
        echo ""
        echo "Usage: $0 [framework|unit]"
        echo ""
        echo "Available frameworks:"
        _get_available_frameworks | sed 's/^/  - /'
        echo ""
        echo "Or run 'unit' to run only unit tests"
        echo "Or run without arguments to run all tests"
        exit 1
    fi

    echo "Validating $language results..."
    echo "================================"
    _run_framework_tests "$language"
    exit $?
fi
