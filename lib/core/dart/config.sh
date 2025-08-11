TEST_FILE_PATTERN='*test.dart'

TEST_FUNCTION_PATTERNS=('testWidgets(' 'test(' 'testBloc<' 'testGoldens(')

# Format the test function patterns to remove any trailing characters like '<' or '(' and output them
# as a space separated string.
function get_test_function_pattern_names() {
    local -a names=()
    for pattern in "${TEST_FUNCTION_PATTERNS[@]}"; do
        clean_name="${pattern%(*}"
        clean_name="${clean_name%<*}"
        names+=("$clean_name")
    done
    echo "${names[@]}"
}
