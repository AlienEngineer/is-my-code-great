#!/usr/bin/env bash
set -euo pipefail

export DIR="examples/dart" 
export FRAMEWORK="dart" 
export DETAILED="false"

source lib/core/dart/config.sh
source lib/core/files.sh
source lib/core/tests.sh
source lib/core/details_stub.sh
source lib/validations/dart/setups-inside-test.sh

echo "Testing find_when_in_tests..."
find_when_in_tests
