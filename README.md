# is-my-code-great
Command-line tool to verify code quality and test patterns. Supports Dart, C#, and Node.js with framework-agnostic validations.

## Use it as a GitHub Action
### is-my-code-great@v0

```
    - name: is my code great?
      uses: alienengineer/is-my-code-great@v0
      with:
        verbose: true       # Optional, set to true for detailed output
        path: "."           # Optional, sets the path to analyze
```

## Install

```sh
brew tap AlienEngineer/tap
brew install is-my-code-great
```

For Windows users, see [Brew for Windows](https://docs.brew.sh/Installation#linux-or-windows-10-subsystem-for-linux).


## Usage
Navigate to the root folder you would like to evaluate, or specify a path:

```sh
# Validate current directory (auto-detects framework)
is-my-code-great

# Validate specific path
is-my-code-great /path/to/project

# Verbose output for debugging
is-my-code-great -v

# Generate detailed HTML report
is-my-code-great -d

# Parseable output (for CI/CD integration)
is-my-code-great -p

# Show help
is-my-code-great --help
```

## Update

```sh
brew update
brew upgrade is-my-code-great
```

## Testing

### Run Unit Tests
```sh
# All unit tests (requires Bats-core)
./test/unit/run_tests.sh

# Specific test file
bats test/unit/test_files.bats

# Install Bats on macOS
brew install bats-core
```

### Run Integration Tests
```sh
# All frameworks
./test/validate_results.sh

# Specific framework
./test/validate_results.sh dart
./test/validate_results.sh csharp
./test/validate_results.sh node
```

Integration tests validate that validations correctly detect issues in example projects under [examples/](examples/).

## Architecture

### Directory Structure
```
bin/is-my-code-great         # CLI entry point
lib/
  analysis.sh                # Main analysis orchestrator
  core/                      # Framework-agnostic utilities
    builder.sh               # Validation registration system
    constants.sh             # Global constants (PAGINATION_SIZE, MAX_TEST_LINES)
    details.sh               # HTML report detail collection
    errors.sh                # Error handling utilities
    files.sh                 # File discovery and iteration (with caching)
    framework-detect.sh      # Auto-detect project type
    tests.sh                 # Test function detection
    text-finders.sh          # Text search helpers
    verbosity.sh             # Verbose output functions
    {FRAMEWORK}/config.sh    # Framework-specific configuration
    report/
      html.sh                # HTML report generation
      terminal.sh            # Terminal output formatting
  awk/                       # Extracted AWK scripts for readability
    find_big_test_functions.awk
    find_single_test_files.awk
  validations/
    agnostic/                # Framework-agnostic validations
    {FRAMEWORK}/             # Framework-specific validations
examples/{FRAMEWORK}/        # Example code for integration tests
test/
  unit/                      # Unit tests (Bats-core)
  {FRAMEWORK}/expected_results.sh  # Integration test expectations
  validate_results.sh        # Integration test runner
```

### Execution Flow
1. **CLI Entry**: [bin/is-my-code-great](bin/is-my-code-great) parses arguments
2. **Framework Detection**: [lib/core/framework-detect.sh](lib/core/framework-detect.sh) identifies project type (Dart/C#/Node)
3. **Analysis Pipeline**: [lib/analysis.sh](lib/analysis.sh) orchestrates:
   - Sources framework config from `lib/core/{FRAMEWORK}/config.sh`
   - Sources core utilities (files, tests, text-finders)
   - Loads validations from `lib/validations/{FRAMEWORK}/*.sh` and `lib/validations/agnostic/*.sh`
   - Executes registered validations
   - Collects results
4. **Reporting**: Outputs via [lib/core/report/terminal.sh](lib/core/report/terminal.sh) or [lib/core/report/html.sh](lib/core/report/html.sh)

### Key Features
- **Pagination**: Large file sets processed in chunks (PAGINATION_SIZE=200) to avoid memory issues
- **Caching**: File lists cached on first access for performance
- **Security**: No `eval` usage, function names validated, variables always quoted
- **AWK Extraction**: Complex AWK scripts in `lib/awk/` for maintainability

## Add New Validations

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed instructions. Quick template:

```sh
#!/usr/bin/env bash
set -euo pipefail

# Description: Detects violations of X pattern
# Severity: CRITICAL|HIGH|LOW

function my_custom_validation() {
    # Use helper functions from lib/core/text-finders.sh
    sum_test_results "-nE" "pattern_regex"
    
    # OR for custom logic:
    # local count=0
    # while read -r line; do
    #     add_details "$line"  # For HTML report
    #     count=$((count + 1))
    # done < <(get_test_files | xargs grep -nE "pattern" 2>/dev/null)
    # echo "$count"
}

# Register test validation
register_test_validation \
    "my-validation-key" \
    "HIGH" \
    "my_custom_validation" \
    "Description of what this validates"

# OR register code validation
# register_code_validation \
#     "my-code-check" \
#     "CRITICAL" \
#     "my_custom_validation" \
#     "Description"
```

**Important**:
- Function names: `snake_case` only (alphanumeric + underscores)
- Validation keys: `hyphenated-format`
- Return: Numeric count (0 or positive), or -1 if N/A
- Add examples to `examples/{FRAMEWORK}/`
- Update `test/{FRAMEWORK}/expected_results.sh`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Coding standards ([CONVENTIONS.md](CONVENTIONS.md))
- Testing guidelines
- Pull request process

## License

MIT License - see [LICENSE](LICENSE) file for details.
