# Contributing to is-my-code-great

Thank you for contributing! This guide will help you get started.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/alienengineer/is-my-code-great.git
cd is-my-code-great

# Run the tool
./bin/is-my-code-great

# Run unit tests
./test/unit/run_tests.sh

# Run integration tests (validates all frameworks)
./test/validate_results.sh
```

## Development Setup

### Requirements
- Bash 5.x or higher
- Git 2.x or higher
- [Bats-core](https://bats-core.readthedocs.io/) 1.13.0+ for unit tests
- shellcheck (optional, for linting)

### Install Bats (for unit tests)
```bash
# macOS
brew install bats-core

# Linux
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

## Coding Standards

### Overview
This project follows strict bash coding conventions. See [CONVENTIONS.md](CONVENTIONS.md) for comprehensive guidelines.

### Quick Reference
- **Functions**: `snake_case` (e.g., `count_violations`)
- **Validation keys**: `hyphenated` (e.g., `big-test-files`)
- **Variables**: `UPPERCASE` for globals, `lowercase` for locals
- **Return values**: `0` = success, `1` = failure, `-1` = N/A
- **Strict mode**: All scripts use `set -euo pipefail`

### Code Formatting
Use `.editorconfig` settings (enforced in your editor):
- Indent: 4 spaces (no tabs)
- Line endings: LF
- Trim trailing whitespace
- Final newline required

## Testing

### Unit Tests
Unit tests use [Bats-core](https://bats-core.readthedocs.io/) framework:

```bash
# Run all unit tests
./test/unit/run_tests.sh

# Run specific test file
bats test/unit/test_files.bats

# Run with verbose output
bats -t test/unit/test_files.bats
```

**Test files**:
- `test/unit/test_*.bats` - Unit tests for core modules
- `test/unit/test_helper.bash` - Shared test utilities
- `test/unit/setup.sh` - Test environment setup

### Integration Tests
Integration tests validate validations against example projects:

```bash
# Run all framework tests
./test/validate_results.sh

# Test specific framework
./test/validate_results.sh dart
./test/validate_results.sh csharp
./test/validate_results.sh node
```

**How it works**:
1. Runs tool against `examples/{FRAMEWORK}/` directory
2. Compares output to `test/{FRAMEWORK}/expected_results.sh`
3. Fails if counts don't match

## Adding a New Validation

### 1. Create Validation Script
Create `lib/validations/{FRAMEWORK}/{validation-name}.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Description: Detects violations of X pattern
# Critical/High/Low: Determines severity

function count_my_violation() {
    # Use helper functions from lib/core/text-finders.sh
    sum_test_results "-nE" "bad_pattern_regex"
    
    # OR for custom logic with details:
    local count=0
    while read -r line; do
        add_details "$line"  # For HTML report (-d flag)
        count=$((count + 1))
    done < <(get_test_files | xargs grep -nE "pattern" 2>/dev/null)
    
    echo "$count"
}
```

**Function naming**: Use `snake_case` with alphanumeric and underscores only. No hyphens or special characters (security requirement).

### 2. Register Validation
In the same file, register your validation:

```bash
register_test_validation \
    "my-violation-key" \
    "CRITICAL" \
    "count_my_violation" \
    "Detects bad pattern X in test files"

# OR for production code:
register_code_validation \
    "my-code-check" \
    "HIGH" \
    "check_production_code" \
    "Validates pattern Y in code files"
```

**Parameters**:
- `key`: Hyphenated identifier (e.g., `big-test-files`)
- `severity`: `CRITICAL`, `HIGH`, or `LOW`
- `function`: Function name (must match shell function)
- `description`: Human-readable description

### 3. Add Example Code
Create `examples/{FRAMEWORK}/my-violation-example.{ext}`:

```dart
// Example that triggers the validation
void badExample() {
    // Code that violates the rule
}
```

### 4. Update Expected Results
Edit `test/{FRAMEWORK}/expected_results.sh`:

```bash
# Add your validation key and expected count
MY_VIOLATION_KEY="2"  # Number of violations in examples
```

### 5. Run Tests
```bash
# Validate your changes
./test/validate_results.sh {FRAMEWORK}

# Should see your validation in output with correct count
```

## Available Helper Functions

### Text Finding (lib/core/text-finders.sh)
```bash
# Count pattern in test files
sum_test_results "-nE" "regex_pattern"

# Count pattern in code files
sum_code_results "-F" "exact.string"

# Get matching lines
find_regex_in_test "pattern" "$DIR"
find_text_in_files "string" "$DIR"
```

### File Operations (lib/core/files.sh)
```bash
# Get all test files (cached, handles git-diff mode)
get_test_files

# Get all code files (excludes tests, lock files)
get_code_files

# Iterate paginated (for large file sets)
iterate_test_files "process_function"
```

### Test Utilities (lib/core/tests.sh)
```bash
# Count all test functions
get_total_tests

# Get framework test patterns
get_test_function_pattern_names
```

### Details for HTML Report
```bash
# Add detail line (only shown with -d flag)
add_details "Found violation at: $file:$line"
```

## Pull Request Guidelines

### Before Submitting
1. **Run all tests**: `./test/unit/run_tests.sh && ./test/validate_results.sh`
2. **Check shellcheck**: `shellcheck bin/is-my-code-great lib/**/*.sh`
3. **Follow conventions**: Review [CONVENTIONS.md](CONVENTIONS.md)
4. **Update VERSION**: Bump version following [Semantic Versioning](https://semver.org/)
   - MAJOR: Breaking changes
   - MINOR: New features (backward compatible)
   - PATCH: Bug fixes

### PR Checklist
- [ ] Tests pass locally
- [ ] New validations have integration test expectations
- [ ] Code follows naming conventions (`snake_case` functions)
- [ ] Functions include doc comments
- [ ] VERSION file updated
- [ ] CHANGELOG.md updated (if user-facing changes)
- [ ] No `cd` usage (use `git -C`, `pushd/popd`, or subshells)
- [ ] No `eval` usage (security risk)
- [ ] Variables quoted: `"$var"` not `$var`

### Commit Messages
Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add validation for bad pattern X
fix: correct regex in violation detector
docs: update contributing guidelines
test: add unit tests for files module
refactor: extract AWK script to lib/awk/
```

### PR Title Format
```
feat: Add validation for {pattern}
fix: Correct {issue} in {module}
docs: Update {documentation}
test: Add tests for {module}
```

## Architecture Overview

### Directory Structure
```
bin/is-my-code-great         # CLI entry point
lib/
  analysis.sh                # Main analysis pipeline
  core/                      # Core utilities (framework-agnostic)
    builder.sh               # Validation registration system
    constants.sh             # Global constants (PAGINATION_SIZE, etc.)
    details.sh               # HTML report detail collection
    errors.sh                # Error handling utilities
    files.sh                 # File discovery and iteration
    framework-detect.sh      # Auto-detect project framework
    tests.sh                 # Test function detection
    text-finders.sh          # Text search helpers
    verbosity.sh             # Verbose output functions
    {FRAMEWORK}/
      config.sh              # Framework-specific configuration
    report/
      html.sh                # HTML report generation
      terminal.sh            # Terminal output formatting
  awk/                       # Complex AWK scripts (extracted for readability)
    find_big_test_functions.awk
    find_single_test_files.awk
  validations/
    agnostic/                # Framework-agnostic validations
      law-of-demeter.sh
    {FRAMEWORK}/             # Framework-specific validations
      big-test-files.sh
      mock-abuse.sh
      verifies.sh
      ...
examples/
  {FRAMEWORK}/               # Example code for integration tests
test/
  unit/                      # Unit tests (Bats-core)
    test_*.bats
    test_helper.bash
    setup.sh
  {FRAMEWORK}/
    expected_results.sh      # Integration test expectations
  validate_results.sh        # Integration test runner
```

### Execution Flow
1. **Entry**: `bin/is-my-code-great` parses CLI args
2. **Detection**: `lib/core/framework-detect.sh` identifies project type
3. **Analysis**: `lib/analysis.sh` orchestrates validation pipeline:
   - Sources framework config from `lib/core/{FRAMEWORK}/config.sh`
   - Sources core utilities (files, tests, text-finders)
   - Loads validations from `lib/validations/{FRAMEWORK}/*.sh`
   - Executes registered validations
4. **Reporting**: Outputs results via `lib/core/report/terminal.sh` or `lib/core/report/html.sh`

### Adding a New Framework
1. Create `lib/core/{FRAMEWORK}/config.sh` with:
   - File extension patterns
   - Test file detection logic
   - Lock file patterns
   - `get_code_files` and `get_test_files` implementations
2. Create `lib/validations/{FRAMEWORK}/` directory
3. Add validations following the pattern above
4. Create `examples/{FRAMEWORK}/` with example violations
5. Create `test/{FRAMEWORK}/expected_results.sh`
6. Update `lib/core/framework-detect.sh` detection logic

## Common Pitfalls

### ❌ Don't Do This
```bash
# Don't use cd
cd "$DIR"
count=$(find . -name "*.dart" | wc -l)

# Don't leave variables unquoted
file=$1
grep "$pattern" $file  # FAILS with spaces in filename

# Don't use eval
eval "$command"  # Security risk

# Don't use hyphens in function names
function count-violations() { ... }  # Security validation fails
```

### ✅ Do This Instead
```bash
# Use git -C or subshells
count=$(git -C "$DIR" ls-files "*.dart" | wc -l)
# OR
count=$(
    cd "$DIR"
    find . -name "*.dart" | wc -l
)

# Always quote variables
file="$1"
grep "$pattern" "$file"

# Never use eval - refactor to avoid it
"$command"  # Direct execution

# Use snake_case
function count_violations() { ... }
```

## Getting Help

- **Documentation**: Start with [README.md](README.md) and [CONVENTIONS.md](CONVENTIONS.md)
- **Examples**: Look at existing validations in `lib/validations/`
- **Tests**: Study test files for usage patterns
- **Issues**: [Open an issue](https://github.com/alienengineer/is-my-code-great/issues) for questions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
