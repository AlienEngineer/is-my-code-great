#!/usr/bin/env bash
# Quick status check for Phase 1.1 tests

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "========================================"
echo "Phase 1.1 Test Status"
echo "========================================"
echo ""

# Check if bats is installed
if command -v bats &> /dev/null; then
    echo -e "${GREEN}✓${NC} bats-core installed: $(bats --version)"
else
    echo -e "${RED}✗${NC} bats-core not installed"
    echo "  Run: brew install bats-core"
    echo ""
    exit 1
fi

echo ""
echo "Test Files Status:"
echo "----------------------------------------"

# Count tests in each file
for test_file in "$PROJECT_ROOT"/test/unit/*.bats; do
    if [[ -f "$test_file" ]]; then
        filename=$(basename "$test_file" .bats)
        total_tests=$(bats --count "$test_file" 2>/dev/null || echo "0")
        
        # Count skipped tests
        skipped=$(grep -c "skip" "$test_file" || echo "0")
        
        # Calculate active tests
        active=$((total_tests - skipped))
        
        if [[ $active -eq $total_tests ]]; then
            status_color=$GREEN
            status="All active"
        elif [[ $active -eq 0 ]]; then
            status_color=$YELLOW
            status="All skipped"
        else
            status_color=$BLUE
            status="$active active, $skipped skipped"
        fi
        
        printf "  %-30s %2d tests  ${status_color}%s${NC}\n" "$filename" "$total_tests" "$status"
    fi
done

echo ""
echo "Files to be Created:"
echo "----------------------------------------"

# Check if implementation files exist
files_to_create=(
    "lib/core/errors.sh:Error handling utilities"
)

for entry in "${files_to_create[@]}"; do
    IFS=':' read -r filepath description <<< "$entry"
    full_path="$PROJECT_ROOT/$filepath"
    
    if [[ -f "$full_path" ]]; then
        echo -e "  ${GREEN}✓${NC} $filepath"
    else
        echo -e "  ${YELLOW}⧗${NC} $filepath - $description"
    fi
done

echo ""
echo "Scripts to Modify (add set -euo pipefail):"
echo "----------------------------------------"

# Count scripts with and without strict mode
total_scripts=0
strict_scripts=0
non_strict_scripts=()

# Check bin
if [[ -f "$PROJECT_ROOT/bin/is-my-code-great" ]]; then
    total_scripts=$((total_scripts + 1))
    if grep -q "^set -[euo]*pipefail" "$PROJECT_ROOT/bin/is-my-code-great"; then
        strict_scripts=$((strict_scripts + 1))
    else
        non_strict_scripts+=("bin/is-my-code-great")
    fi
fi

# Check lib/analysis.sh
if [[ -f "$PROJECT_ROOT/lib/analysis.sh" ]]; then
    total_scripts=$((total_scripts + 1))
    if grep -q "^set -[euo]*pipefail" "$PROJECT_ROOT/lib/analysis.sh"; then
        strict_scripts=$((strict_scripts + 1))
    else
        non_strict_scripts+=("lib/analysis.sh")
    fi
fi

# Check core libs
while IFS= read -r file; do
    total_scripts=$((total_scripts + 1))
    if grep -q "^set -[euo]*pipefail" "$file"; then
        strict_scripts=$((strict_scripts + 1))
    else
        rel_path="${file#$PROJECT_ROOT/}"
        non_strict_scripts+=("$rel_path")
    fi
done < <(find "$PROJECT_ROOT/lib/core" -name "*.sh" -type f)

# Check validations
while IFS= read -r file; do
    total_scripts=$((total_scripts + 1))
    if grep -q "^set -[euo]*pipefail" "$file"; then
        strict_scripts=$((strict_scripts + 1))
    else
        rel_path="${file#$PROJECT_ROOT/}"
        non_strict_scripts+=("$rel_path")
    fi
done < <(find "$PROJECT_ROOT/lib/validations" -name "*.sh" -type f)

echo "  Total scripts: $total_scripts"
echo -e "  ${GREEN}With strict mode:${NC} $strict_scripts"
echo -e "  ${YELLOW}Without strict mode:${NC} ${#non_strict_scripts[@]}"

if [[ ${#non_strict_scripts[@]} -gt 0 ]]; then
    echo ""
    echo "  Files needing 'set -euo pipefail':"
    for script in "${non_strict_scripts[@]}"; do
        echo "    - $script"
    done
fi

echo ""
echo "Next Steps:"
echo "----------------------------------------"

if ! command -v bats &> /dev/null; then
    echo "  1. Install bats-core: brew install bats-core"
elif [[ ! -f "$PROJECT_ROOT/lib/core/errors.sh" ]]; then
    echo "  1. Create lib/core/errors.sh"
    echo "  2. Implement die(), warn(), debug(), setup_error_traps()"
    echo "  3. Unskip tests in test/unit/test_errors.bats"
    echo "  4. Run: bats test/unit/test_errors.bats"
else
    echo "  1. Continue implementing Phase 1.1 features"
    echo "  2. Unskip tests incrementally"
    echo "  3. Run: ./test/unit/run_tests.sh"
fi

echo ""
echo "Quick Commands:"
echo "  Run all tests:     ./test/unit/run_tests.sh"
echo "  Run error tests:   bats test/unit/test_errors.bats"
echo "  Run strict tests:  bats test/unit/test_strict_mode.bats"
echo "  Integration tests: ./test/validate_results.sh"
echo ""
