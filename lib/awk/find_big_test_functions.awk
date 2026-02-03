#!/usr/bin/awk -f
# find_big_test_functions.awk
#
# Identifies test functions that exceed a specified line count threshold.
# Used to detect overly long test methods that should be refactored.
#
# Input:
#   - Lines from grep output: "filename:lineno:content"
#   - grep pattern matches: test(), testWidgets(), testGoldens(), closing braces
#   - Variable: max_lines (passed via -v flag)
#
# Output:
#   - For each oversized test: "filename:lineno: (N lines) test_name"
#
# Usage:
#   grep -nE 'pattern' files | awk -v max_lines=15 -f find_big_test_functions.awk
#
# Algorithm:
#   1. Track brace depth within each test function
#   2. When depth returns to 0, test function is complete
#   3. Report if line count exceeds threshold

# Report a test function if it exceeds the line threshold
function report(file, name, start, end) {
    if (name != "" && end >= start && (end - start) > max_lines) {
        printf("%s:%d: (%d lines) %s\n", file, start, end-start, name)
    }
}

# Extract line number from grep output (format: file:lineno:content)
function get_line_number(line) {
    split(line, parts, ":")
    return parts[2]
}

# Extract filename from grep output
function get_file(line) {
    split(line, parts, ":")
    return parts[1]
}

# Extract function name/test description from grep output
function get_funcname(line) {
    split(line, parts, ":")
    return parts[3]
}

# Match start of test functions
/testWidgets\(|test\(|testGoldens\(/ {
    inTest = 1
    count = 0
    depth = 1
    funcname = get_funcname($0)
    startline = get_line_number($0) + 1
    next
}

# Track opening braces (increase depth)
inTest && /\{/ {
    depth++
    next
}

# Track closing braces (decrease depth)
inTest && /\}/ {
    depth--
    if (depth == 0) {
        # Test function complete - report if too large
        report(get_file($0), funcname, startline, get_line_number($0))
        inTest = 0
        funcname = ""
    }
}
