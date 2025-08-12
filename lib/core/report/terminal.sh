function dump_summary() {   
    local totalTests=$(get_total_tests)
    local totalIssues=$(get_total_issues)
    if [ "$totalIssues" -gt 0 ]; then
        printf "Nop!\n\n"

        printf "%-40s %10d\n" "Total Tests:" "$totalTests"
        printf "%-40s %10d\n\n" "Total Issues Found:" "$totalIssues"

        printf "%-40s %10s %-10s %15s\n" "Issues on Tests:" "#" "Severity" "Execution Time"
        get_validations | while read -r validation; do
            printf "%-40s %10d %-10s %15s\n" \
                "$(get_title "$validation")" \
                "$(get_result "$validation")" \
                "$(get_severity "$validation")" \
                "$(get_execution_time "$validation")ms"
        done
    else
        echo "Oh My God! You've done good!"
    fi

    printf "\n\nCode evaluated in %d ms\n" "$(get_total_execution_time)"
}