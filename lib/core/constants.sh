#!/usr/bin/env bash
# Constants used across the codebase
# Centralizes magic numbers for maintainability

set -euo pipefail

# Guard against multiple sourcing
[[ -n "${_CONSTANTS_SOURCED:-}" ]] && return 0
readonly _CONSTANTS_SOURCED=true

# Pagination size for iterating through large file lists
# Used to avoid loading thousands of filenames into memory
readonly PAGINATION_SIZE=200

# Maximum number of lines for a test function before flagging as "big"
readonly MAX_TEST_LINES=15
