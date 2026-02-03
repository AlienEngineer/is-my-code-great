# Copilot Instructions for is-my-code-great

## Overview
A CLI tool for code quality validation across multiple languages (Dart, C#, Node.js). It analyzes code to verify best practices and test quality, with support for framework-specific and language-agnostic validations.

## Commands

### Run the tool locally
```bash
./bin/is-my-code-great [OPTIONS] [PATH]
```

### Common usage patterns
```bash
# Validate current directory (auto-detects framework)
./bin/is-my-code-great

# Validate specific path
./bin/is-my-code-great /path/to/project

# Compare against a specific base branch
./bin/is-my-code-great -b main /path/to/project

# Verbose output for debugging
./bin/is-my-code-great -v

# Parseable output (for CI/CD integration)
./bin/is-my-code-great -p
```

### Test validation
Framework-specific validation tests are in `/test`. To validate results for a language:
```bash
./test/validate_results.sh dart    # Validate Dart examples
./test/validate_results.sh csharp  # Validate C# examples
./test/validate_results.sh node    # Validate Node examples
./test/validate_results.sh         # Run all framework tests
```

### Additional flags
```bash
# Generate detailed HTML report
./bin/is-my-code-great -d

# Analyze multiple projects (each with framework marker file)
./bin/is-my-code-great --per-project /path/to/multi-project

# Quick git-based check (against main branch)
./bin/is-my-code-great -g
```

## Architecture

### Framework Detection
- `lib/core/framework-detect.sh` - Auto-detects framework based on file presence (pubspec.yaml for Dart, .csproj for C#, package.json for Node)
- Frameworks are specified as directories under `lib/core/{FRAMEWORK}` and `lib/validations/{FRAMEWORK}`

### Analysis Flow
1. **Entry point**: `bin/is-my-code-great` parses CLI arguments
2. **Framework detection**: `lib/core/framework-detect.sh` identifies the project type
3. **Analysis execution**: `lib/analysis.sh` orchestrates the validation pipeline:
   - Sources framework-specific config from `lib/core/{FRAMEWORK}/config.sh`
   - Sources language-agnostic core utilities (files, git_diff, tests, text-finders)
   - Loads all validations from `lib/validations/{FRAMEWORK}/*.sh` and `lib/validations/agnostic/*.sh`
   - Executes registered validations and collects results

### Validation System
Validations are registered via two functions in `lib/core/builder.sh`:
- `register_test_validation` - For test-specific quality checks
- `register_code_validation` - For production code quality checks

**Security:** Validation functions are invoked directly (no `eval`). Function names are validated to contain only alphanumeric characters and underscores. This prevents command injection vulnerabilities.

**Function name requirements:**
- Must start with a letter or underscore
- Can only contain: `[a-zA-Z0-9_]`
- Invalid examples: `rm -rf /`, `echo; malicious_cmd`, `func-with-hyphens`
- Valid examples: `count_violations`, `get_verifies_count`, `_private_helper`

Each validation receives:
- `$DIR` - The project directory being analyzed
- Helper functions from core modules (text-finders, file utilities, git diffing)
- Returns: Number or result for the validation

### Core Modules
- `lib/core/verbosity.sh` - Print functions for verbose output
- `lib/core/tests.sh` - Test detection and iteration utilities
  - `get_total_tests()` - Count all test functions in the project
  - `get_test_function_pattern_names()` - Get test function patterns for the framework
- `lib/core/files.sh` - File pattern matching with caching (excludes test, lock files, node_modules, etc.)
  - `get_code_files()` - Returns all production code files (cached)
  - `get_test_files()` - Returns all test files (cached)
  - Automatically switches between local filesystem and git diff modes
- `lib/core/text-finders.sh` - Text search helpers for validations
  - `sum_test_results(flags, pattern)` - Count grep matches in test files
  - `sum_code_results(flags, pattern)` - Count grep matches in code files
  - `find_text_in_test(pattern, dir)` - Simple text search in test files
  - `find_regex_in_test(pattern, dir)` - Regex search in test files
  - `find_text_in_files(pattern, dir)` - Simple text search in all files
  - `find_regex_in_files(pattern, dir)` - Regex search in all files
- `lib/core/git_diff.sh` - Git branch comparison utilities
  - `get_changed_code_files()` - Production files changed between branches
  - `get_changed_test_files()` - Test files changed between branches
- `lib/core/builder.sh` - Validation registration and execution framework
- `lib/core/details.sh` - Detail collection for HTML reports
  - `add_details(message)` - Add a detail line to current validation (for `-d` flag)
- `lib/core/report/terminal.sh` - Terminal output formatting
- `lib/core/report/html.sh` - HTML report generation (when `--detailed` flag used)

### Adding a New Validation
1. Create `lib/validations/{FRAMEWORK}/{validation-name}.sh`
2. Implement function: `function my_validation_name() { ... }`
   - **IMPORTANT:** Use only `snake_case` with alphanumeric and underscores
   - Function names are security-validated; hyphens and special characters are rejected
3. Register it:
   ```bash
   register_test_validation \
       "unique-key" \
       "CRITICAL|HIGH|LOW" \
       "my_validation_name" \
       "Human-readable description"
   ```
4. Add test expectations to `test/{FRAMEWORK}/expected_results.sh`
5. Ensure examples exist in `examples/{FRAMEWORK}/` that trigger the validation
6. Run `./test/validate_results.sh {FRAMEWORK}` to verify

**Example validation using core helpers:**
```bash
function count_my_issue() {
  # Using sum_test_results for simple grep count
  sum_test_results "-n" "badPattern"
  
  # OR using get_test_files for custom logic
  local count=0
  while read -r line; do
    add_details "$line"  # For detailed HTML report
    count=$((count + 1))
  done < <(get_test_files | xargs grep -n "badPattern" 2>/dev/null)
  echo "$count"
}
```

## Key Conventions

### Framework-Specific Configuration
Each supported framework has:
- `lib/core/{FRAMEWORK}/config.sh` - Defines framework-specific variables and helper functions:
  - `get_code_files` - Returns code files (excludes tests)
  - `get_test_files` - Returns test files
  - `get_lock_file_patterns` - Lock file patterns to ignore
  - Framework-specific file extensions and patterns
- `lib/validations/{FRAMEWORK}/` - Framework-specific validation scripts
- `test/{FRAMEWORK}/expected_results.sh` - Expected validation counts for examples
- `examples/{FRAMEWORK}/` - Example projects demonstrating each validation

### Validation Key Naming
Keys used in `register_*_validation` should be hyphenated (e.g., `tests-per-file`, `big-test-files`) and match the shell function name pattern `snake_case_function`.

### Return Values
- Validations return numeric counts or results (0 or positive integers expected)
- Return -1 to indicate "check not applicable" or skip the validation
- The tool summarizes validation results in terminal and HTML output

### File Handling
- `get_code_files` excludes: test files, lock files, node_modules, .git, etc.
- `get_test_files` filters for framework-specific test file patterns
- Use these functions via `lib/core/files.sh` helpers: `get_code_files`, `get_test_files`
- Files are cached on first call for performance; cache automatically handles local vs git-diff mode
- When adding details for HTML reports, call `add_details "$line"` before counting

### Git Diff Mode
When `-b/--base` flag is used, git diff against the base branch. Functions available:
- `get_changed_code_files` - Files changed between branches
- `get_changed_test_files` - Test files changed between branches
- Use `LOCAL_RUN` variable to determine if comparing branches or local directory
- File helper functions automatically adapt to git-diff mode when `LOCAL_RUN=false`

## Testing Tips
- Examples serve as test cases; validations should match expected result counts
- Use `-v` flag when debugging validation logic
- Use `-p` flag to see parseable output (easier for testing)
- Each language has separate validation sets; avoid assuming Dart rules apply to Node
- Test runner compares actual output against `test/{FRAMEWORK}/expected_results.sh`
- When a validation test fails, check both the validation logic and the example code in `examples/{FRAMEWORK}/`

## CI/CD Integration
The tool includes GitHub Actions workflows:
- **validate_pr.yml** - Runs on PRs, validates version bump, runs tests for all frameworks
- **publish.yml** - Publishes releases to Homebrew tap
- **merge_main.yml** - Runs on main branch merges

Using as a GitHub Action in other repos:
```yaml
- name: is my code great?
  uses: alienengineer/is-my-code-great@v0
  with:
    base-branch: main   # Optional
    verbose: true       # Optional
```
