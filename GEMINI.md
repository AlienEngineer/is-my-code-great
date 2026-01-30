# Project: is-my-code-great

## Project Overview

`is-my-code-great` is a command-line interface (CLI) tool designed to verify various aspects of test and production code. It currently supports Dart and C# (with extensibility for other frameworks) and can be integrated into CI/CD pipelines as a GitHub Action. The tool works by executing a series of modular validation scripts written in Bash, each checking for specific code quality or style issues. Results can be output in a human-readable format or a machine-parseable key-value format.

## Technologies Used

*   **Bash:** Core scripting language for the CLI and validation logic.
*   **Git:** Used for branch comparison in analysis.
*   **GitHub Actions:** For CI/CD integration and automated code quality checks.

## Architecture

The project follows a modular architecture based on shell scripts:

*   **`bin/is-my-code-great`:** The main executable script. It handles argument parsing, framework detection, and orchestrates the analysis flow.
*   **`lib/analysis.sh`:** Contains the core analysis logic. It sources various utility scripts and then loads and executes validation scripts based on the detected (or specified) framework.
*   **`lib/core/`:** A directory containing foundational utility scripts, such as:
    *   `builder.sh`: Manages the registration and execution of individual validations, collecting their results and execution times.
    *   `framework-detect.sh`: Detects the project's framework (e.g., Dart, Node, C#) by looking for characteristic files like `pubspec.yaml`, `package.json`, or `.csproj`.
    *   Other utilities for verbosity, file operations, git diffs, text finding, and test-related functions.
*   **`lib/validations/`:** Contains the actual validation scripts, organized by framework (`dart`, `csharp`, `node`) and a common `agnostic` directory for cross-framework checks. Each validation script defines a function that performs a specific check and registers itself with the `builder.sh` functions (`register_test_validation` or `register_code_validation`).
*   **`action.yml`:** Defines the GitHub Action for the tool, allowing it to be run in CI workflows. It fetches branches, executes the `is-my-code-great` CLI, and comments results back to pull requests.

## Building and Running

The tool is primarily distributed via `brew`.

### Installation

```bash
brew tap AlienEngineer/tap
brew install is-my-code-great
```

### Usage

Navigate to the root folder you want to evaluate or specify a path.

```bash
# Analyze the current directory (auto-detects framework)
is-my-code-great

# Get help
is-my-code-great --help

# Analyze a Dart project in a specific directory
is-my-code-great -f dart /path/to/project

# Analyze multiple Dart projects within a directory (each with a pubspec.yaml)
is-my-code-great --per-project /path/to/multiple/projects

# Perform a quick check against the main branch (git-based analysis)
is-my-code-great -g

# Perform a quick check against a specific base branch
is-my-code-great -b master

# Perform a detailed report (html)
is-my-code-great -d
```

### Updating

```bash
brew update
brew upgrade is-my-code-great
```

## Development Conventions

### Adding New Validations

New validations are implemented as Bash scripts within `lib/validations/` (either in a framework-specific subdirectory or `agnostic`). They define functions to perform checks and register themselves using `register_test_validation` or `register_code_validation`, specifying a unique key, severity (LOW, HIGH, CRITICAL), and a description.

```bash
#!/usr/bin/env bash

# Example validation function
function my_custom_validation() {
  # Implementation using $DIR, core functions like get_code_files, etc.
  echo 0 # Return the count of issues found
}

# Registering a test validation
register_test_validation \
    "unique-check-key" \
    "HIGH" \
    "my_custom_validation" \
    "Description of the validation check."
```

## Testing

The project includes an automated testing suite to verify the correctness of the validation rules.

### Test Structure

*   `test/validate_results.sh`: The main test runner script.
*   `test/<language>/expected_results.sh`: Contains the expected key-value pairs of validation results for example code in `examples/<language>/`.

### Running Tests

```bash
# Run tests for a specific language (e.g., Dart)
./test/validate_results.sh dart

# Run tests for all available frameworks
./test/validate_results.sh
```

The test script runs `is-my-code-great` with the `--parseable` flag on example code and compares the output against predefined expected results. It reports PASS/FAIL for each validation rule.
