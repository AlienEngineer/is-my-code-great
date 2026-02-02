set -euo pipefail

CODE_FILE_PATTERN="*.dart"
TEST_FILE_PATTERN='*test.dart'
TEST_FUNCTION_PATTERNS=('testWidgets(' 'test(' 'testGoldens(')