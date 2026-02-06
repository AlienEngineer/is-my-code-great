#!/usr/bin/env bash
set -euo pipefail

# framework-detect.sh: Detects the project framework (dart, csharp, etc.)

# Usage: detect_framework <directory> [<verbose>]
# Prints the detected framework to stdout, or exits 1 if not found.

detect_framework() {
    local dir="$1"
    local verbose="${2:-0}"
    
    # Validate required parameters
    if [[ -z "$dir" ]]; then
        echo "Error: directory parameter required for detect_framework" >&2
        return 1
    fi
    
    # Validate directory exists
    if [[ ! -d "$dir" ]]; then
        echo "Error: directory does not exist: $dir" >&2
        return 1
    fi
    
    if [ "$verbose" = "1" ]; then
        echo "[framework-detect] Scanning directory: $dir" >&2
    fi
    
    # Use find -quit to stop after first match, avoiding broken pipe errors
    # when grep -q exits early in strict pipefail mode
    if [[ -n "$(find "$dir" \( -name "pubspec.yaml" -o -name "*.dart" \) -print -quit 2>/dev/null)" ]]; then
        [ "$verbose" = "1" ] && echo "[framework-detect] Detected Dart project" >&2
        echo "dart"
        return 0
    elif [[ -n "$(find "$dir" \( -name "package.json" -o -name "*.ts" \) -print -quit 2>/dev/null)" ]]; then
        [ "$verbose" = "1" ] && echo "[framework-detect] Detected NodeJs project" >&2
        echo "node"
        return 0
    elif [[ -n "$(find "$dir" \( -name "*.csproj" -o -name "*.cs" \) -print -quit 2>/dev/null)" ]]; then
        [ "$verbose" = "1" ] && echo "[framework-detect] Detected C# project" >&2
        echo "csharp"
        return 0
    else
        [ "$verbose" = "1" ] && echo "[framework-detect] Could not detect framework" >&2
        return 1
    fi
}
