set -euo pipefail

CODE_FILE_PATTERN="*.ts"
TEST_FILE_PATTERN='*spec.ts'
TEST_FUNCTION_PATTERNS=('it(' 'test.each')