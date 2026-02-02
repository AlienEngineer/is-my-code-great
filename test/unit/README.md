# Phase 1.1 Testing Documentation

## Overview

This directory contains unit tests for Phase 1.1: Error Handling Infrastructure. Following **Test-Driven Development (TDD)**, these tests were written **before** implementing the actual features.

## Test Structure

```
test/unit/
├── test_helper.bash           # Shared test utilities and setup/teardown
├── test_errors.bats           # Tests for lib/core/errors.sh functions
├── test_strict_mode.bats      # Tests for set -euo pipefail integration
├── test_phase1_integration.bats # Integration tests after changes
└── run_tests.sh               # Test runner script
```

## Prerequisites

Install bats-core (Bash Automated Testing System):

```bash
# macOS
brew install bats-core

# Ubuntu/Debian
sudo apt-get install bats

# From source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

## Running Tests

### Run all unit tests
```bash
./test/unit/run_tests.sh
```

### Run specific test file
```bash
bats test/unit/test_errors.bats
bats test/unit/test_strict_mode.bats
bats test/unit/test_phase1_integration.bats
```

### Run with verbose output
```bash
bats --formatter tap test/unit/test_errors.bats
```

## Test Status

Most tests are currently **SKIPPED** because the implementation hasn't started yet. As you implement Phase 1.1 features:

1. Remove the `skip` line from tests
2. Run the tests (they should fail - Red)
3. Implement the feature
4. Run the tests again (they should pass - Green)
5. Refactor if needed

## Test Files Explained

### test_helper.bash
Shared utilities for all tests:
- `setup()` / `teardown()` - Test lifecycle management
- `assert_*` functions - Assertion helpers
- `mock_function()` - Function mocking
- `create_mock_file()` - Test fixture creation

### test_errors.bats
Tests for the new `lib/core/errors.sh` file:
- `die()` - Fatal error handler with cleanup
- `warn()` - Non-fatal warning messages
- `debug()` - Verbose mode logging
- `setup_error_traps()` - Signal handlers (EXIT, ERR, INT)
- Cleanup function integration
- Error context (file:line) in messages

### test_strict_mode.bats
Tests for `set -euo pipefail` integration:
- All scripts have strict mode enabled
- Scripts fail on undefined variables
- Scripts fail on command errors in pipelines
- Scripts exit on command failures
- Proper shebangs in all executable scripts

### test_phase1_integration.bats
Integration tests ensuring the tool still works:
- Dart example analysis
- C# example analysis
- Node example analysis
- Verbose mode functionality
- Git diff mode functionality
- Error handling for invalid inputs
- HTML report generation
- Existing test suite compatibility

## TDD Workflow Example

Let's implement `die()` function using TDD:

### 1. Red - Tests fail (already done)
```bash
bats test/unit/test_errors.bats
# Most tests are skipped, but structure is ready
```

### 2. Green - Make tests pass

Unskip the first test in `test_errors.bats`:
```bash
# Remove 'skip "Waiting..."' line from a test
```

Create `lib/core/errors.sh`:
```bash
#!/usr/bin/env bash
# Error handling utilities

die() {
    local message="$1"
    echo "ERROR: $message" >&2
    exit 1
}
```

Run tests:
```bash
bats test/unit/test_errors.bats
# Test should now pass
```

### 3. Refactor - Improve implementation

Add more features (cleanup, context, etc.):
```bash
die() {
    local message="$1"
    local caller_info="${BASH_SOURCE[1]}:${BASH_LINENO[0]}"
    
    echo "ERROR [$caller_info]: $message" >&2
    
    # Call cleanup if defined
    if [[ -n "${CLEANUP_FUNC:-}" ]] && declare -f "$CLEANUP_FUNC" > /dev/null; then
        "$CLEANUP_FUNC" 2>/dev/null || true
    fi
    
    exit 1
}
```

Unskip more tests and repeat until all tests pass.

## Expected Test Output

When all tests are passing:

```
========================================
Running Unit Tests for Phase 1.1
========================================

Running: test_errors
----------------------------------------
✓ test_errors tests passed

Running: test_strict_mode
----------------------------------------
✓ test_strict_mode tests passed

Running: test_phase1_integration
----------------------------------------
✓ test_phase1_integration tests passed

========================================
Test Summary
========================================
Total test files: 3
✓ Passed: 3

✓ All test files passed!
```

## Writing New Tests

Follow this template:

```bash
#!/usr/bin/env bats

load test_helper

setup() {
    source "$(dirname "$BATS_TEST_DIRNAME")/test_helper.bash"
    setup
}

teardown() {
    source "$(dirname "$BATS_TEST_DIRNAME")/test_helper.bash"
    teardown
}

@test "descriptive test name" {
    # Arrange
    local test_file="$TEST_TEMP_DIR/test.sh"
    cat > "$test_file" <<'EOF'
#!/usr/bin/env bash
echo "test"
EOF
    
    # Act
    run bash "$test_file"
    
    # Assert
    assert_exit_status 0
    assert_output_contains "test"
}
```

## CI Integration

Add to `.github/workflows/validate_pr.yml`:

```yaml
- name: Run unit tests
  run: |
    brew install bats-core
    ./test/unit/run_tests.sh
```

## Next Steps

1. Start implementing `lib/core/errors.sh`
2. Unskip tests one at a time
3. Make each test pass
4. Add `set -euo pipefail` to scripts
5. Unskip strict mode tests
6. Fix any issues that surface
7. Run integration tests
8. Update audit plan checkboxes

## Reference

- [bats-core documentation](https://bats-core.readthedocs.io/)
- [Bash strict mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/)
- [TDD workflow](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
