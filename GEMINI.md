# Project Overview

`is-my-code-great` is a command-line tool designed to analyze and validate code against a set of configurable rules. It is built with shell scripts, making it lightweight and easy to extend. The tool supports multiple programming languages through a framework-based architecture, with current support for C#, Dart, and Node.js.

The main goal of this project is to provide a simple yet powerful way to enforce coding standards and best practices in a language-agnostic manner. It can be used locally or integrated into a CI/CD pipeline as a GitHub Action.

## How it Works

The tool operates by scanning the specified directory for code files that match the patterns defined for the detected or specified framework. It then runs a series of validations against these files.

Validations are simple shell scripts that perform specific checks, such as counting the occurrences of a certain pattern or checking for the presence of a specific file. The results are then collected and displayed in the terminal.

### Core Components

*   **`bin/is-my-code-great`**: The main executable script. It handles command-line arguments, detects the framework, and initiates the analysis.
*   **`lib/analysis.sh`**: The core script that orchestrates the analysis process. It loads the necessary framework configurations and validation scripts.
*   **`lib/core/`**: This directory contains the core shell scripts that provide the building blocks for the tool. This includes functions for detecting frameworks, finding files, registering validations, and generating reports.
*   **`lib/validations/`**: This directory contains the validation scripts, organized by framework. There is also an `agnostic` directory for validations that can be applied to any framework.

## Building and Running

There is no build process for this project since it is composed of shell scripts.

### Running the tool

To run the tool, you can use the `is-my-code-great` executable located in the `bin` directory.

```sh
./bin/is-my-code-great <path>
```

You can also specify the framework and other options:

```sh
./bin/is-my-code-great -f <framework> -v <path>
```

### Testing

The project has a test suite that validates the results of the analysis. To run the tests, you can execute the `test/validate_results.sh` script.

```sh
./test/validate_results.sh
```

## Development Conventions

### Adding a new validation

To add a new validation, you need to create a new shell script in the appropriate framework directory under `lib/validations/`. The script should define a function that performs the validation and then register it using the `register_test_validation` or `register_code_validation` function.

Here is an example of a validation script:

```sh
#!/usr/bin/env bash

function get_verifies_count() {
    find_text_in_test '.Verify('
}

register_test_validation \
    "verifies" \
    "HIGH" \
    "get_verifies_count" \
    "Verify method calls:"
```

### Code Style

The project uses shell scripts. There is no specific style guide enforced, but the existing code follows a consistent style. When adding new code, try to follow the existing conventions.
