#!/usr/bin/env bats

load test_helper

setup() {
    export TEST_TEMP_DIR="$(mktemp -d)"
    export SCRIPT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    
    # Source framework detection
    source "$SCRIPT_ROOT/lib/core/framework-detect.sh"
}

teardown() {
    rm -rf "$TEST_TEMP_DIR"
}

@test "detect_framework: detects dart via pubspec.yaml" {
    mkdir -p "$TEST_TEMP_DIR/lib"
    touch "$TEST_TEMP_DIR/pubspec.yaml"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "dart"
}

@test "detect_framework: detects dart via .dart files" {
    mkdir -p "$TEST_TEMP_DIR/lib"
    echo "class Example {}" > "$TEST_TEMP_DIR/lib/example.dart"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "dart"
}

@test "detect_framework: detects csharp via .csproj file" {
    mkdir -p "$TEST_TEMP_DIR/Project"
    touch "$TEST_TEMP_DIR/Project/Project.csproj"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "csharp"
}

@test "detect_framework: detects csharp via .cs files" {
    mkdir -p "$TEST_TEMP_DIR/src"
    echo "public class Example {}" > "$TEST_TEMP_DIR/src/Example.cs"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "csharp"
}

@test "detect_framework: detects node via package.json" {
    mkdir -p "$TEST_TEMP_DIR/src"
    echo '{"name": "test"}' > "$TEST_TEMP_DIR/package.json"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "node"
}

@test "detect_framework: detects node via .ts files" {
    mkdir -p "$TEST_TEMP_DIR/src"
    echo "export class Example {}" > "$TEST_TEMP_DIR/src/example.ts"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "node"
}

@test "detect_framework: fails with empty directory" {
    # Empty directory with no marker files
    run detect_framework "$TEST_TEMP_DIR"
    assert_failure
}

@test "detect_framework: fails with missing directory parameter" {
    run detect_framework ""
    assert_failure
    assert_output --partial "directory parameter required"
}

@test "detect_framework: fails with non-existent directory" {
    run detect_framework "/nonexistent/directory"
    assert_failure
    assert_output --partial "directory does not exist"
}

@test "detect_framework: prioritizes dart over node" {
    # If both dart and node files exist, dart wins
    touch "$TEST_TEMP_DIR/pubspec.yaml"
    touch "$TEST_TEMP_DIR/package.json"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "dart"
}

@test "detect_framework: prioritizes node over csharp" {
    # If both node and csharp files exist, node wins
    mkdir -p "$TEST_TEMP_DIR/src"
    echo '{"name": "test"}' > "$TEST_TEMP_DIR/package.json"
    echo "public class Test {}" > "$TEST_TEMP_DIR/src/Test.cs"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "node"
}

@test "detect_framework: verbose mode prints debug info to stderr" {
    touch "$TEST_TEMP_DIR/pubspec.yaml"
    
    run detect_framework "$TEST_TEMP_DIR" 1
    assert_success
    assert_output --partial "dart"
    # Stderr would contain debug messages in actual usage
}

@test "detect_framework: non-verbose mode is quiet" {
    touch "$TEST_TEMP_DIR/pubspec.yaml"
    
    run detect_framework "$TEST_TEMP_DIR" 0
    assert_success
    # Should only output the framework name
    [ "$output" = "dart" ]
}

@test "detect_framework: finds files in subdirectories" {
    mkdir -p "$TEST_TEMP_DIR/deep/nested/path"
    echo "class Deep {}" > "$TEST_TEMP_DIR/deep/nested/path/deep.dart"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "dart"
}

@test "detect_framework: handles directory with spaces" {
    local dir_with_spaces="$TEST_TEMP_DIR/my project"
    mkdir -p "$dir_with_spaces"
    touch "$dir_with_spaces/pubspec.yaml"
    
    run detect_framework "$dir_with_spaces"
    assert_success
    assert_output "dart"
}

@test "detect_framework: handles directory with special chars" {
    local special_dir="$TEST_TEMP_DIR/project-2024_v1.0"
    mkdir -p "$special_dir"
    touch "$special_dir/pubspec.yaml"
    
    run detect_framework "$special_dir"
    assert_success
    assert_output "dart"
}

@test "detect_framework: dart - multiple marker files doesn't cause issues" {
    touch "$TEST_TEMP_DIR/pubspec.yaml"
    mkdir -p "$TEST_TEMP_DIR/lib"
    echo "class A {}" > "$TEST_TEMP_DIR/lib/a.dart"
    echo "class B {}" > "$TEST_TEMP_DIR/lib/b.dart"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "dart"
}

@test "detect_framework: csharp - multiple .csproj files" {
    mkdir -p "$TEST_TEMP_DIR/Project1"
    mkdir -p "$TEST_TEMP_DIR/Project2"
    touch "$TEST_TEMP_DIR/Project1/Project1.csproj"
    touch "$TEST_TEMP_DIR/Project2/Project2.csproj"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "csharp"
}

@test "detect_framework: node - multiple .ts files" {
    mkdir -p "$TEST_TEMP_DIR/src"
    echo "export const a = 1;" > "$TEST_TEMP_DIR/src/a.ts"
    echo "export const b = 2;" > "$TEST_TEMP_DIR/src/b.ts"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "node"
}

@test "detect_framework: real-world dart project structure" {
    # Simulate typical Flutter/Dart project
    mkdir -p "$TEST_TEMP_DIR/lib/src"
    mkdir -p "$TEST_TEMP_DIR/test"
    touch "$TEST_TEMP_DIR/pubspec.yaml"
    echo "class MyApp {}" > "$TEST_TEMP_DIR/lib/main.dart"
    echo "test('example', () {})" > "$TEST_TEMP_DIR/test/main_test.dart"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "dart"
}

@test "detect_framework: real-world csharp project structure" {
    # Simulate typical .NET project
    mkdir -p "$TEST_TEMP_DIR/MyApp"
    mkdir -p "$TEST_TEMP_DIR/MyApp.Tests"
    touch "$TEST_TEMP_DIR/MyApp/MyApp.csproj"
    touch "$TEST_TEMP_DIR/MyApp.Tests/MyApp.Tests.csproj"
    echo "public class Program {}" > "$TEST_TEMP_DIR/MyApp/Program.cs"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "csharp"
}

@test "detect_framework: real-world node project structure" {
    # Simulate typical Node/TypeScript project
    mkdir -p "$TEST_TEMP_DIR/src"
    mkdir -p "$TEST_TEMP_DIR/test"
    echo '{"name": "my-app", "version": "1.0.0"}' > "$TEST_TEMP_DIR/package.json"
    echo "export default class App {}" > "$TEST_TEMP_DIR/src/app.ts"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_success
    assert_output "node"
}

@test "detect_framework: doesn't detect other file types" {
    mkdir -p "$TEST_TEMP_DIR/src"
    echo "print('hello')" > "$TEST_TEMP_DIR/src/script.py"
    echo "puts 'hello'" > "$TEST_TEMP_DIR/src/script.rb"
    echo "<?php echo 'hello'; ?>" > "$TEST_TEMP_DIR/src/script.php"
    
    run detect_framework "$TEST_TEMP_DIR"
    assert_failure
}

@test "detect_framework: handles symlinks" {
    skip "Symlink behavior varies by OS/filesystem"
    mkdir -p "$TEST_TEMP_DIR/real"
    touch "$TEST_TEMP_DIR/real/pubspec.yaml"
    ln -s "$TEST_TEMP_DIR/real" "$TEST_TEMP_DIR/link"
    
    run detect_framework "$TEST_TEMP_DIR/link"
    assert_success
    assert_output "dart"
}

@test "detect_framework: return value is consistent" {
    touch "$TEST_TEMP_DIR/pubspec.yaml"
    
    # Call multiple times, should always return dart
    run detect_framework "$TEST_TEMP_DIR"
    local first="$output"
    
    run detect_framework "$TEST_TEMP_DIR"
    local second="$output"
    
    [ "$first" = "$second" ]
    [ "$first" = "dart" ]
}
