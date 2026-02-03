# Coding Conventions for is-my-code-great

This document outlines the coding standards and conventions used in this bash project.

## Naming Conventions

### Functions
- Use `snake_case` for all function names
- Private/internal functions start with underscore: `_helper_function`
- Valid examples: `count_violations`, `get_verifies_count`, `_validate_git_repo`
- Invalid: `countViolations`, `GetVerifiesCount`, `validate-git-repo`

**Security:** Function names are validated to contain only `[a-zA-Z0-9_]` to prevent command injection.

### Variables
- **Global variables**: `UPPERCASE_WITH_UNDERSCORES`
  - Examples: `SCRIPT_ROOT`, `TEST_FILE_PATTERN`, `PAGINATION_SIZE`
  - Use `readonly` for constants: `readonly MAX_TEST_LINES=15`
  
- **Local variables**: `lowercase_with_underscores`
  - Examples: `local file_count=0`, `local test_dir="$1"`
  - Always declare with `local` in functions

- **Exported variables**: `UPPERCASE` (used across scripts)
  - Examples: `DIR`, `FRAMEWORK`, `VERBOSE`, `DETAILED`

### Validation Keys
- Use hyphenated format: `big-test-files`, `tests-per-file`, `mock-abuse`
- Must match the corresponding snake_case function name pattern

## Return Value Conventions

### Standard Return Codes
- `0` - Success
- `1` - Failure/Error
- `-1` - Not applicable (validations only - check doesn't apply)

### Output Conventions
- **stdout**: Function results, data to be captured
- **stderr**: Error messages, warnings, debug info

### Examples
```bash
function my_validation() {
    local count=0
    # ... do work ...
    echo "$count"  # Output to stdout
    return 0       # Success
}

function validate_input() {
    if [[ -z "$1" ]]; then
        echo "Error: parameter required" >&2  # Error to stderr
        return 1
    fi
    return 0
}
```

## Error Handling

### Strict Mode
All bash scripts must include:
```bash
set -euo pipefail
```

- `-e`: Exit on error
- `-u`: Exit on undefined variable
- `-o pipefail`: Catch errors in pipes

### Error Functions
Use utility functions from `lib/core/errors.sh`:
- `die "message"` - Fatal error, exits with cleanup
- `warn "message"` - Warning to stderr, continues
- `debug "message"` - Debug output when VERBOSE=true

### Guard Clauses
Validate inputs early:
```bash
function process_file() {
    local file="$1"
    
    # Guard clauses at top
    [[ -z "$file" ]] && { echo "File required" >&2; return 1; }
    [[ ! -f "$file" ]] && { echo "File not found: $file" >&2; return 1; }
    
    # Main logic
    # ...
}
```

## Comment Guidelines

### When to Comment
- **Do comment:** Non-obvious logic, workarounds, algorithm explanations
- **Don't comment:** Obvious operations, self-documenting code

### Good Comments
```bash
# Paginate to avoid loading thousands of filenames into memory
# mapfile with null terminator handles filenames with spaces/newlines safely
mapfile -d '' -t files < <(find "$DIR" -name "*.dart" -print0)

# Cache results to avoid repeated expensive find operations
CODE_FILES_CACHE_READY=true
```

### Bad Comments
```bash
# Get the count  # Obvious from function name
count=$(get_count)

# Loop through files  # Obvious from code
for file in "${files[@]}"; do
```

## Code Organization

### File Structure
```bash
#!/usr/bin/env bash
set -euo pipefail

# Source dependencies (with shellcheck directives)
# shellcheck source=lib/core/constants.sh
source "$(dirname "${BASH_SOURCE[0]}")/constants.sh"

# Global constants
readonly MY_CONSTANT="value"

# Private functions (prefixed with _)
_helper_function() {
    # ...
}

# Public functions
public_function() {
    # ...
}
```

### Function Size
- Target: < 50 lines per function
- If longer, consider extracting helpers
- One clear responsibility per function

## Shell Script Patterns

### Variable Quoting
Always quote variables to handle spaces:
```bash
# Good
if [[ -f "$file" ]]; then
    process_file "$file"
fi

# Bad
if [[ -f $file ]]; then  # Breaks with spaces
    process_file $file
fi
```

### Array Handling
```bash
# Declare arrays
declare -a my_array=()

# Append to arrays
my_array+=("item")

# Iterate safely
for item in "${my_array[@]}"; do
    echo "$item"
done

# Get array length
local count="${#my_array[@]}"
```

### Command Substitution
Use `$()` not backticks:
```bash
# Good
result=$(command)

# Bad
result=`command`
```

### Conditional Tests
Use `[[ ]]` for bash conditionals:
```bash
# Good
if [[ -f "$file" && -r "$file" ]]; then

# Avoid (unless POSIX required)
if [ -f "$file" ] && [ -r "$file" ]; then
```

## Text Processing

### Grep Patterns
```bash
# Simple string search
grep -F "exact.string" file

# Regex search
grep -E "pattern|alternative" file

# Count matches
grep -c "pattern" file

# Null-safe file input
grep -h "pattern" -- "${files[@]}"
```

### AWK Scripts
- Complex AWK (>10 lines) goes in `lib/awk/` directory
- Include header comment explaining purpose
- Document inputs and outputs
- Example: `lib/awk/find_big_test_functions.awk`

### Find Commands
```bash
# Use null terminators for safety
find "$DIR" -name "*.dart" -print0

# Exclude common directories
find "$DIR" -name "node_modules" -prune -o -name "*.ts" -print
```

## Testing

### Unit Tests
- Use bats-core framework
- One test file per module: `test/unit/test_<module>.bats`
- Setup/teardown for test isolation
- Use descriptive test names

### Test Naming
```bash
@test "function_name: behavior description" {
    # Test body
}
```

Examples:
- `get_test_files: returns all test files`
- `detect_framework: fails with empty directory`
- `sum_results: counts matches correctly`

## Performance

### File Operations
- Cache file lists when possible
- Use pagination for large file sets (see `PAGINATION_SIZE`)
- Prefer `mapfile` over loops for reading files

### Git Operations
- Use `git -C "$DIR"` instead of `cd`
- Batch operations when possible
- Cache git diff results

## Security

### Command Injection Prevention
- Never use `eval` with user input
- Validate function names: only `[a-zA-Z0-9_]`
- Quote all variables
- Use `--` to end option processing: `grep -- "$pattern"`

### Path Handling
- Use absolute paths
- Use `realpath` or `cd && pwd` for resolution
- Handle spaces and special characters

## Documentation

### Function Documentation
For complex functions, include:
```bash
# function_name: Brief description
#
# Usage: function_name <param1> <param2>
# Returns: 0 on success, 1 on failure
#
# Example:
#   count=$(function_name "$dir" "pattern")
```

### Module Headers
Each module should have:
```bash
#!/usr/bin/env bash
set -euo pipefail

# module-name.sh: Purpose of this module
#
# Exported functions:
# - public_function_one
# - public_function_two
```

## Version Control

### Commit Messages
Follow conventional commits:
- `feat: add new validation`
- `fix: correct path resolution`
- `refactor: extract helper function`
- `test: add unit tests for files.sh`
- `docs: update README with testing info`

### Branch Names
- Feature: `feat/description`
- Bug fix: `fix/description`
- Refactor: `refactor/description`

## See Also

- `.editorconfig` - Editor formatting configuration
- `test/unit/README.md` - Unit testing guide
- `.github/copilot-instructions.md` - AI coding assistant guidance
- `CONTRIBUTING.md` - Contributing guidelines
