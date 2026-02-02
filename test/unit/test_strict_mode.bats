#!/usr/bin/env bats
# Unit tests for set -euo pipefail integration
# Tests that all scripts properly use strict mode and handle errors correctly

load test_helper

setup() {
    TEST_TEMP_DIR="$(mktemp -d)"
    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
}

teardown() {
    if [[ -d "${TEST_TEMP_DIR:-}" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Test: bin/is-my-code-great has set -euo pipefail
@test "bin/is-my-code-great should have set -euo pipefail" {
    run grep -E "^set -[euo]+ pipefail" "$PROJECT_ROOT/bin/is-my-code-great"
    assert_exit_status 0
}

# Test: lib/analysis.sh has set -euo pipefail
@test "lib/analysis.sh should have set -euo pipefail" {
    run grep -E "^set -[euo]+ pipefail" "$PROJECT_ROOT/lib/analysis.sh"
    assert_exit_status 0
}

# Test: All core library files have set -euo pipefail
@test "all lib/core/*.sh files should have set -euo pipefail" {
    local missing=()
    
    while IFS= read -r file; do
        # Skip files that only define functions (sourced, not executed)
        # They inherit pipefail from the sourcing script
        if ! grep -q "^set -[euo]\+ pipefail" "$file"; then
            missing+=("$file")
        fi
    done < <(find "$PROJECT_ROOT/lib/core" -name "*.sh" -type f)
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Files missing 'set -euo pipefail':"
        printf '%s\n' "${missing[@]}"
        return 1
    fi
}

# Test: All validation files have set -euo pipefail
@test "all validation files should have set -euo pipefail" {
    local missing=()
    
    while IFS= read -r file; do
        if ! grep -q "^set -[euo]\+ pipefail" "$file"; then
            missing+=("$file")
        fi
    done < <(find "$PROJECT_ROOT/lib/validations" -name "*.sh" -type f)
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Files missing 'set -euo pipefail':"
        printf '%s\n' "${missing[@]}"
        return 1
    fi
}

# Test: Scripts fail on undefined variables
@test "scripts should fail when using undefined variables" {
    skip "Waiting for set -euo pipefail implementation"
    
    local test_script="$TEST_TEMP_DIR/test_undefined.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "$UNDEFINED_VAR"
EOF
    chmod +x "$test_script"
    
    run "$test_script" 2>&1
    # Should fail with non-zero exit
    [[ $status -ne 0 ]]
    # Should contain error about unbound variable
    [[ "$output" =~ (unbound|undefined) ]]
}

# Test: Scripts fail on command errors in pipelines
@test "scripts should fail on command errors in pipelines" {
    skip "Waiting for set -euo pipefail implementation"
    
    local test_script="$TEST_TEMP_DIR/test_pipefail.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# First command fails, pipeline should fail
false | true | true
echo "This should not execute"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    [[ $status -ne 0 ]]
    assert_output_not_contains "This should not execute"
}

# Test: Scripts exit on command failures
@test "scripts should exit on command failures" {
    skip "Waiting for set -euo pipefail implementation"
    
    local test_script="$TEST_TEMP_DIR/test_errexit.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

false
echo "This should not execute"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    [[ $status -ne 0 ]]
    assert_output_not_contains "This should not execute"
}

# Test: Optional commands can use || true to avoid exit
@test "scripts can use || true for optional commands" {
    skip "Waiting for set -euo pipefail implementation"
    
    local test_script="$TEST_TEMP_DIR/test_optional.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# This is allowed to fail
false || true

echo "Script continues"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    assert_exit_status 0
    assert_output_contains "Script continues"
}

# Test: Scripts can check exit status explicitly
@test "scripts can check exit status with if statements" {
    skip "Waiting for set -euo pipefail implementation"
    
    local test_script="$TEST_TEMP_DIR/test_if_check.sh"
    cat > "$test_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if false; then
    echo "Should not reach"
else
    echo "Handled failure"
fi

echo "Script continues"
EOF
    chmod +x "$test_script"
    
    run "$test_script"
    assert_exit_status 0
    assert_output_contains "Handled failure"
    assert_output_contains "Script continues"
}

# Test: Sourced files without shebang don't need set -euo pipefail
@test "library files inherit pipefail from sourcing script" {
    skip "Waiting for set -euo pipefail implementation"
    
    # Create library file without pipefail
    local lib_file="$TEST_TEMP_DIR/mylib.sh"
    cat > "$lib_file" <<'EOF'
# Library file - no shebang, no set -euo pipefail needed

my_function() {
    echo "Function works"
}
EOF
    
    # Create script that sources it
    local test_script="$TEST_TEMP_DIR/test_source.sh"
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
set -euo pipefail

source "$lib_file"
my_function

# Should still fail on undefined var
echo "\$UNDEFINED"
EOF
    chmod +x "$test_script"
    
    run "$test_script" 2>&1
    # Should fail due to undefined variable
    [[ $status -ne 0 ]]
}

# Test: Each script file starts with proper shebang
@test "executable scripts should have #!/usr/bin/env bash shebang" {
    local bad_shebangs=()
    
    # Check bin directory
    while IFS= read -r file; do
        if [[ -x "$file" ]]; then
            local shebang
            shebang="$(head -n1 "$file")"
            if [[ ! "$shebang" =~ ^#!/usr/bin/env\ bash ]]; then
                bad_shebangs+=("$file: $shebang")
            fi
        fi
    done < <(find "$PROJECT_ROOT/bin" -type f)
    
    if [[ ${#bad_shebangs[@]} -gt 0 ]]; then
        echo "Files with incorrect shebangs:"
        printf '%s\n' "${bad_shebangs[@]}"
        return 1
    fi
}

# Test: set -euo pipefail is on line 2 or 3 (after shebang and optional comment)
@test "set -euo pipefail should be near the top of scripts" {
    skip "Waiting for set -euo pipefail implementation"
    
    local misplaced=()
    
    while IFS= read -r file; do
        if [[ -x "$file" ]]; then
            # Check that set -euo pipefail appears in first 5 lines
            if ! head -n5 "$file" | grep -q "^set -[euo]*pipefail"; then
                misplaced+=("$file")
            fi
        fi
    done < <(find "$PROJECT_ROOT/bin" "$PROJECT_ROOT/lib" -name "*.sh" -type f)
    
    if [[ ${#misplaced[@]} -gt 0 ]]; then
        echo "Files with misplaced 'set -euo pipefail':"
        printf '%s\n' "${misplaced[@]}"
        return 1
    fi
}
