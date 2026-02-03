set -euo pipefail

function export_report() {
    if [[ "${DETAILED:-}" != "true" ]]; then
        return
    fi
    
    # Ensure the detailed file exists and its empty
    echo "" > "$DETAILED_FILE"
    # shellcheck disable=SC2140,SC1078,SC1079
    print_to_file "
<html lang="en">
    <head><title>Detailed Results</title></head>
    <meta charset="UTF-8">
    <style>
        html,body{
            margin:0;
            padding:0;
            background:#fff;
            color:#111;
            font:14px/1.5 -apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Ubuntu,Arial
        }
        h1{
            text-align:center;
            margin:24px 0;
            color:#1f8fff;
        }
        .note{
            text-align:center;
            margin:0 0 24px;
            color:#666;
        }
        .card{
            max-width:1000px;
            margin:24px auto;
            padding:18px 22px 22px;
            background:#fff;
            border:2px solid #1f8fff;
            border-radius:14px;
            position:relative;
        }
        .card-header{
            display:flex;
            justify-content:space-between;
            align-items:center;
            cursor:pointer;
        }
        .card .title{
            margin:0;
            font-size:20px;
            font-weight:700;
            color:#1f8fff;
        }
        .card .severity{
            margin:0;
            font-weight:800;
            letter-spacing:.5px;
            color:#f5a623;
        }
        /* Severity Colors */
        .card .severity.low {
            color:#1f8fff; /* Blue */
        }
        .card .severity.high {
            color:#f5a623; /* Orange (current HIGH color) */
        }
        .card .severity.critical {
            color:#d32f2f; /* Red */
        }
        .card-content{
            margin-top:12px;
        }
        .card a{
            display:block;
            margin:8px 0;
            text-decoration:none;
            color:#111;
        }
        .card a:hover{ 
            text-decoration:underline; 
        }
        .card .found{
            position:absolute;
            right: 227px;
            margin:0;
            font-weight:700;
            color:#111;
        }
        .card .elapsed{
            position:absolute;
            right: 100px;
            margin:0;
            color:#111;
        }
        /* collapsed state */
        .card.collapsed .card-content{
            display:none;
        }
        /* Success state when Found = 0 */
        .card.success {
            border-color: #2e7d32 !important; /* green border */
        }
        .card.success .title {
            color: #2e7d32 !important; /* green title */
        }
    </style>
"

    print_to_file "
    <body>
        <h1>Detailed Validation Results</h1>
        <p class='note'>Click on the titles to expand details.</p>
    "

    print_to_file "
        <div class='card collapsed'>
            <div class='card-header'>
                <h2>Production Code Validations</h2>
            </div>
            <div class='card-content'>
    "
    get_production_validations | while read -r validation; do
        local found severity elapsed title
        found=$(get_result "$validation")
        severity=$(get_severity "$validation")
        elapsed=$(get_execution_time "$validation")
        title=$(get_title "$validation")
        print_to_file "
        <div class='card collapsed'>
            <div class='card-header'>
                <h2 class='title'>$title</h2>
                <span class='found'>Found: $found</span>
                <span class='elapsed'>Elapsed: ${elapsed}ms</span>
                <span class='severity'>$severity</span>
            </div>
            <div class='card-content'>
"
        get_execution_details "$validation" | while read -r detail; do
            file="${detail%%:*}"
            rest="${detail#*:}"
            linenum="${rest%%:*}"
            label="${rest#*:}"

            print_to_file "$(printf '<a href="vscode://file/%s:%s">%s</a>\n' "$file" "$linenum" "$label")"
        done
        print_to_file "
            </div>
        </div>
"
    done

    print_to_file "
        </div>
        </div>
"

    print_to_file "
        <div class='card collapsed'>
            <div class='card-header'>
                <h2>Test Validations</h2>
            </div>
            <div class='card-content'>
    "
    get_test_validations | while read -r validation; do
        local found severity elapsed title
        found=$(get_result "$validation")
        severity=$(get_severity "$validation")
        elapsed=$(get_execution_time "$validation")
        title=$(get_title "$validation")
        print_to_file "
        <div class='card collapsed'>
            <div class='card-header'>
                <h2 class='title'>$title</h2>
                <span class='found'>Found: $found</span>
                <span class='elapsed'>Elapsed: ${elapsed}ms</span>
                <span class='severity'>$severity</span>
            </div>
            <div class='card-content'>
"
        get_execution_details "$validation" | while read -r detail; do
            file="${detail%%:*}"
            rest="${detail#*:}"
            linenum="${rest%%:*}"
            label="${rest#*:}"

            print_to_file "$(printf '<a href="vscode://file/%s:%s">%s</a>\n' "$file" "$linenum" "$label")"
        done
        print_to_file "
            </div>
        </div>
"
    done

    print_to_file "
        </div>
"

    print_to_file "
    </body>
    <script>
        // Toggle collapse on click
        document.querySelectorAll('.card-header').forEach(header => {
            header.addEventListener('click', () => {
                header.parentElement.classList.toggle('collapsed');
            });
        });

        // Auto-assign severity classes & mark success state
        document.querySelectorAll('.card').forEach(card => {
            const severityEl = card.querySelector('.severity');
            const foundEl = card.querySelector('.found');

            if (severityEl) {
                const sevText = severityEl.textContent.trim().toLowerCase();
                severityEl.classList.add(sevText);
            }

            if (foundEl) {
                const match = foundEl.textContent.match(/Found:\s*(\d+)/i);
                if (match && parseInt(match[1], 10) === 0) {
                    card.classList.add('success');
                }
            }
        });
    </script>
</html>"
    open_details_file
}

print_to_file() {
    echo "$1" >> "$DETAILED_FILE"
}

function open_details_file() {
    if [[ "${DETAILED:-}" == "true" ]]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "$DETAILED_FILE" &> /dev/null
        elif command -v open &> /dev/null; then
            open "$DETAILED_FILE" &> /dev/null
        else
            echo "Cannot open details file. Please open $DETAILED_FILE manually."
        fi
    fi
}