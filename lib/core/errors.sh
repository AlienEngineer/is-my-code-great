#!/usr/bin/env bash
set -euo pipefail

# Error handling utilities for is-my-code-great

# Fatal error handler with cleanup support
# Usage: die "error message"
# Set CLEANUP_FUNC to name of cleanup function to call before exit
die() {
    local message="$1"
    local caller_info="${BASH_SOURCE[2]:-unknown}:${BASH_LINENO[1]:-0}"
    
    echo "ERROR [$caller_info]: $message" >&2
    
    # Call cleanup function if defined
    if [[ -n "${CLEANUP_FUNC:-}" ]] && declare -f "$CLEANUP_FUNC" &>/dev/null; then
        "$CLEANUP_FUNC" 2>/dev/null || true
    fi
    
    exit 1
}

# Non-fatal warning handler
# Usage: warn "warning message"
warn() {
    local message="$1"
    echo "WARNING: $message" >&2
}

# Debug output (only when VERBOSE is set)
# Usage: debug "debug message"
debug() {
    local message="$1"
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "DEBUG: $message" >&2
    fi
}

# Setup error traps for EXIT, ERR, and INT signals
# Call this early in scripts that need cleanup on error/exit
# Usage: setup_error_traps
setup_error_traps() {
    # Track if cleanup has been called to prevent multiple executions
    local cleanup_called=false
    
    # Cleanup wrapper that ensures single execution
    _cleanup_once() {
        if [[ "$cleanup_called" == "false" ]]; then
            cleanup_called=true
            if [[ -n "${CLEANUP_FUNC:-}" ]] && declare -f "$CLEANUP_FUNC" &>/dev/null; then
                "$CLEANUP_FUNC" 2>/dev/null || true
            fi
        fi
    }
    
    # ERR trap: catches command failures when set -e is enabled
    trap '_cleanup_once' ERR
    
    # EXIT trap: always runs on script exit (normal or error)
    trap '_cleanup_once' EXIT
    
    # INT trap: handles Ctrl+C gracefully
    trap '_cleanup_once; exit 130' INT
}
