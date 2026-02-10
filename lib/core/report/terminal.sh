set -euo pipefail

function print_summary() {   
    local result_mode="${RESULT_MODE:-combined}"
    
    if [ "$result_mode" = "per-path" ]; then
        print_per_path_summary
    else
        print_combined_summary
    fi
}

function print_combined_summary() {
    local totalTests
    local totalIssues
    totalTests=$(get_total_tests)
    totalIssues=$(get_total_issues)
    
    # Get unique paths
    local -a unique_paths=()
    for path in "${PROJECT_PATH[@]}"; do
        if [[ ! " ${unique_paths[*]} " =~ " ${path} " ]]; then
            unique_paths+=("$path")
        fi
    done
    
    # Aggregate results by validation key (sum counts for same validation across paths)
    declare -A aggregated_results=()
    declare -A aggregated_severity=()
    declare -A aggregated_title=()
    declare -A aggregated_category=()
    declare -A aggregated_time=()
    
    for i in "${!VALIDATION[@]}"; do
        local key="${VALIDATION[$i]}"
        if [[ -z "${aggregated_results[$key]:-}" ]]; then
            aggregated_results[$key]=0
            aggregated_severity[$key]="${SEVERITY[$i]}"
            aggregated_title[$key]="${TITLE[$i]}"
            aggregated_category[$key]="${CATEGORY[$i]}"
            aggregated_time[$key]=0
        fi
        aggregated_results[$key]=$((aggregated_results[$key] + COMMAND[i]))
        aggregated_time[$key]=$((aggregated_time[$key] + EXECUTION_TIME[i]))
    done
    
    if [ "$totalIssues" -gt 0 ]; then
        printf "Nop!\n\n"

        printf "%-40s %10d\n" "Total Tests:" "$totalTests"
        printf "%-40s %10d\n" "Total Issues Found:" "$totalIssues"
        
        # Show analyzed paths
        if [ ${#unique_paths[@]} -gt 1 ]; then
            printf "%-40s %10d\n\n" "Paths Analyzed:" "${#unique_paths[@]}"
        else
            printf "\n"
        fi

        printf "%-40s %10s %-10s %15s\n" "Issues on Production Code:" "#" "Severity" "Execution Time"
        for key in "${!aggregated_results[@]}"; do
            if [[ "${aggregated_category[$key]}" == "PRODUCTION" ]]; then
                printf "%-40s %10d %-10s %15s\n" \
                    "${aggregated_title[$key]}" \
                    "${aggregated_results[$key]}" \
                    "${aggregated_severity[$key]}" \
                    "${aggregated_time[$key]}ms"
            fi
        done


        printf "\n\n"

        printf "%-40s %10s %-10s %15s\n" "Issues on Tests:" "#" "Severity" "Execution Time"
        for key in "${!aggregated_results[@]}"; do
            if [[ "${aggregated_category[$key]}" == "TESTS" ]]; then
                printf "%-40s %10d %-10s %15s\n" \
                    "${aggregated_title[$key]}" \
                    "${aggregated_results[$key]}" \
                    "${aggregated_severity[$key]}" \
                    "${aggregated_time[$key]}ms"
            fi
        done
    else
        printf "YES!\n\n"

        printf "%-40s %10d\n" "Total Tests:" "$totalTests"
        printf "%-40s %10d\n" "Total Issues Found:" "$totalIssues"
        
        # Show analyzed paths
        if [ ${#unique_paths[@]} -gt 1 ]; then
            printf "%-40s %10d\n\n" "Paths Analyzed:" "${#unique_paths[@]}"
        else
            printf "\n"
        fi

        echo "Oh My God! You've done good!"
    fi

    printf "\n\nCode evaluated in %d ms\n" "$(get_total_execution_time)"
}

function print_per_path_summary() {
    # Get unique paths in order of appearance
    local -a unique_paths=()
    for path in "${PROJECT_PATH[@]}"; do
        if [[ ! " ${unique_paths[*]} " =~ " ${path} " ]]; then
            unique_paths+=("$path")
        fi
    done
    
    # Print summary for each path
    for current_path in "${unique_paths[@]}"; do
        printf "\n=== Analysis for: %s ===\n\n" "$current_path"
        
        local path_total_issues=0
        local path_has_results=false
        
        # Calculate issues for this path
        for i in "${!VALIDATION[@]}"; do
            if [[ "${PROJECT_PATH[$i]}" == "$current_path" ]]; then
                path_total_issues=$((path_total_issues + COMMAND[i]))
                path_has_results=true
            fi
        done
        
        if [ "$path_has_results" = false ]; then
            echo "No results for this path"
            continue
        fi
        
        if [ "$path_total_issues" -gt 0 ]; then
            printf "Nop!\n\n"
            printf "%-40s %10d\n\n" "Total Issues Found:" "$path_total_issues"

            printf "%-40s %10s %-10s %15s\n" "Issues on Production Code:" "#" "Severity" "Execution Time"
            for i in "${!VALIDATION[@]}"; do
                if [[ "${PROJECT_PATH[$i]}" == "$current_path" ]] && [[ "${CATEGORY[$i]}" == "PRODUCTION" ]]; then
                    printf "%-40s %10d %-10s %15s\n" \
                        "${TITLE[$i]}" \
                        "${COMMAND[$i]}" \
                        "${SEVERITY[$i]}" \
                        "${EXECUTION_TIME[$i]}ms"
                fi
            done

            printf "\n\n"

            printf "%-40s %10s %-10s %15s\n" "Issues on Tests:" "#" "Severity" "Execution Time"
            for i in "${!VALIDATION[@]}"; do
                if [[ "${PROJECT_PATH[$i]}" == "$current_path" ]] && [[ "${CATEGORY[$i]}" == "TESTS" ]]; then
                    printf "%-40s %10d %-10s %15s\n" \
                        "${TITLE[$i]}" \
                        "${COMMAND[$i]}" \
                        "${SEVERITY[$i]}" \
                        "${EXECUTION_TIME[$i]}ms"
                fi
            done
        else
            printf "YES!\n\n"
            printf "%-40s %10d\n\n" "Total Issues Found:" "$path_total_issues"
            echo "Oh My God! You've done good!"
        fi
    done
    
    # Print overall summary
    printf "\n\n========================================\n"
    printf "Overall Summary (%d path(s))\n" "${#unique_paths[@]}"
    printf "========================================\n\n"
    
    local totalIssues
    totalIssues=$(get_total_issues)
    printf "%-40s %10d\n" "Total Issues Across All Paths:" "$totalIssues"
    printf "Code evaluated in %d ms\n" "$(get_total_execution_time)"
}