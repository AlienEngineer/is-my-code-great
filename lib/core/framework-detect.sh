#!/usr/bin/env bash
# framework-detect.sh: Detects the project framework (dart, csharp, etc.)

# Usage: detect_framework <directory> [<verbose>]
# Prints the detected framework to stdout, or exits 1 if not found.

detect_framework() {
    local dir="$1"
    local verbose="$2"
    if [ "$verbose" = "1" ]; then
        echo "[framework-detect] Scanning directory: $dir" >&2
    fi
    if find "$dir" -name "pubspec.yaml" -o -name "*.dart" | grep -q .; then
        [ "$verbose" = "1" ] && echo "[framework-detect] Detected Dart project" >&2
        echo "dart"
        return 0
    elif find "$dir" -name "package.json" -o -name "*.ts" | grep -q .; then
        [ "$verbose" = "1" ] && echo "[framework-detect] Detected NodeJs project" >&2
        echo "node"
        return 0
    elif find "$dir" -name "*.csproj" -o -name "*.cs" | grep -q .; then
        [ "$verbose" = "1" ] && echo "[framework-detect] Detected C# project" >&2
        echo "csharp"
        return 0
    else
        [ "$verbose" = "1" ] && echo "[framework-detect] Could not detect framework" >&2
        return 1
    fi
}
