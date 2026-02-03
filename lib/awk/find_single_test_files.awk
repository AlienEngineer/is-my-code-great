#!/usr/bin/awk -f
# find_single_test_files.awk
#
# Identifies files that contain exactly one test function.
# Single-test files may indicate incomplete test coverage or poor organization.
#
# Input:
#   - Lines from grep output: "filename:lineno:content"
#   - grep pattern matches test function declarations
#
# Output:
#   - For files with exactly 1 test: "filename:lineno"
#
# Usage:
#   grep -nE 'test_pattern' files | awk -f find_single_test_files.awk
#
# Algorithm:
#   1. Count tests per file as we process grep output
#   2. When file changes, report previous file if it had exactly 1 test
#   3. Handle last file in END block

BEGIN {
    test_count = 0
    prev_file = ""
    prev_lineno = 0
}

{
    # Parse grep output: filename:lineno:content
    split($0, parts, ":")
    file = parts[1]
    lineno = parts[2]
    
    # When we encounter a new file, check if previous file had single test
    if (prev_file != file && prev_file != "") {
        if (test_count == 1) {
            printf("%s:%d \n", prev_file, prev_lineno)
        }
        test_count = 0
    }
    
    # Track current file and increment test count
    prev_file = file
    prev_lineno = lineno
    test_count++
}

# Check the last file processed
END {
    if (test_count == 1) {
        printf("%s:%d \n", prev_file, prev_lineno)
    }
}
