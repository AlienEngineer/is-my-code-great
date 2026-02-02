#!/usr/bin/env bash
# Test runner for unit tests
# Requires: bats-core (brew install bats-core)

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$PROJECT_ROOT/test/unit"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    print_error "bats-core is not installed"
    echo ""
    echo "Install with:"
    echo "  macOS:    brew install bats-core"
    echo "  Ubuntu:   sudo apt-get install bats"
    echo "  Manual:   git clone https://github.com/bats-core/bats-core.git && cd bats-core && ./install.sh /usr/local"
    echo ""
    exit 1
fi

print_header "Running Unit Tests for Phase 1.1"

# Track test results
total_tests=0
passed_tests=0
failed_tests=0
skipped_tests=0

# Run each test file
for test_file in "$TEST_DIR"/*.bats; do
    if [[ -f "$test_file" ]]; then
        test_name=$(basename "$test_file" .bats)
        echo ""
        echo "Running: $test_name"
        echo "----------------------------------------"
        
        if bats --formatter tap "$test_file"; then
            print_success "$test_name tests passed"
            ((passed_tests++))
        else
            print_error "$test_name tests failed"
            ((failed_tests++))
        fi
        ((total_tests++))
    fi
done

# Print summary
print_header "Test Summary"

echo "Total test files: $total_tests"
print_success "Passed: $passed_tests"

if [[ $failed_tests -gt 0 ]]; then
    print_error "Failed: $failed_tests"
fi

# Count skipped tests
skipped_count=$(grep -r "skip" "$TEST_DIR"/*.bats | wc -l | tr -d ' ')
if [[ $skipped_count -gt 0 ]]; then
    print_warning "Skipped: $skipped_count individual tests (waiting for implementation)"
fi

echo ""

# Exit with error if any tests failed
if [[ $failed_tests -gt 0 ]]; then
    print_error "Some tests failed. See output above for details."
    exit 1
else
    print_success "All test files passed!"
    echo ""
    echo "Note: Many individual tests are skipped because Phase 1.1"
    echo "      implementation hasn't started yet. As you implement"
    echo "      features, unskip the corresponding tests."
    exit 0
fi
