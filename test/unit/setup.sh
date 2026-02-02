#!/usr/bin/env bash
# Setup script for Phase 1.1 test infrastructure
# Installs bats-core if needed

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${YELLOW}➜${NC} $1"
}

echo ""
echo "========================================"
echo "Phase 1.1 Test Infrastructure Setup"
echo "========================================"
echo ""

# Check if bats is already installed
if command -v bats &> /dev/null; then
    bats_version=$(bats --version)
    print_success "bats-core is already installed: $bats_version"
else
    print_info "bats-core is not installed"
    echo ""
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected macOS. Install with Homebrew:"
        echo "  brew install bats-core"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Detected Linux. Install with:"
        echo "  Ubuntu/Debian: sudo apt-get install bats"
        echo "  Fedora/RHEL:   sudo dnf install bats"
    else
        echo "Install from source:"
        echo "  git clone https://github.com/bats-core/bats-core.git"
        echo "  cd bats-core"
        echo "  sudo ./install.sh /usr/local"
    fi
    
    echo ""
    echo "After installing, run this script again or run:"
    echo "  ./test/unit/run_tests.sh"
    exit 1
fi

echo ""
print_info "Verifying test structure..."

# Check test files exist
test_files=(
    "$PROJECT_ROOT/test/unit/test_helper.bash"
    "$PROJECT_ROOT/test/unit/test_errors.bats"
    "$PROJECT_ROOT/test/unit/test_strict_mode.bats"
    "$PROJECT_ROOT/test/unit/test_phase1_integration.bats"
    "$PROJECT_ROOT/test/unit/run_tests.sh"
)

for file in "${test_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "Found: $(basename "$file")"
    else
        echo "✗ Missing: $file"
        exit 1
    fi
done

echo ""
print_info "Running basic test validation..."

# Try to parse test files
for test_file in "$PROJECT_ROOT"/test/unit/*.bats; do
    if bats --count "$test_file" > /dev/null 2>&1; then
        test_count=$(bats --count "$test_file")
        print_success "$(basename "$test_file"): $test_count tests defined"
    else
        echo "✗ Parse error in: $(basename "$test_file")"
        exit 1
    fi
done

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Run tests:    ./test/unit/run_tests.sh"
echo "  2. Read guide:   cat test/unit/README.md"
echo "  3. Start coding: Implement lib/core/errors.sh"
echo ""
print_info "Note: Most tests are currently skipped (waiting for implementation)"
echo ""
