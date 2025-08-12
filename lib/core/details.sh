
print_to_file() {
    if [[ "${DETAILED:-}" == "true" ]]; then
        echo "$1" >> "$DETAILED_FILE"
    fi
}

function add_details() {
    local line="$1" 
    file=$(echo "$line" | cut -d: -f1)
    linenum=$(echo "$line" | cut -d: -f2 | awk '{print $1}')
    label=$(echo "$line" | sed -E 's/^[^ ]+:[0-9]+ - //')

    print_to_file "$(printf '<a href="vscode://file/%s:%s">%s</a>\n' "$file" "$linenum" "$label")"
}

function add_details_start_evaluation() {
    local title="$1"
    local severity="$2"
    local severity_class="low"
    if [[ "$severity" == "HIGH" ]]; then
        severity_class="high"
    elif [[ "$severity" == "CRITICAL" ]]; then
        severity_class="critical"
    fi 

    print_to_file "
    <div class=\"card collapsed\">
        <div class=\"card-header\">
            <h2 class=\"title\">$title</h2>
            <p class=\"severity $severity_class\">$severity</p>
        </div>
        <div class="card-content">
    "
}

function add_details_end_evaluation() {
    local result="$1"
    local elapsed="$2"

    print_to_file "  
        </div>
        <p class=\"found\">Found: $result</p>
        <p class=\"elapsed\">$elapsed ms</p>
    </div>
    "
}

function init_details_file() {
        # clear file
        if [[ "${DETAILED:-}" == "true" ]]; then
            echo "" > "$DETAILED_FILE"
        fi
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
        .card{
            max-width:1000px;
            margin:24px auto;
            padding:18px 22px 42px;
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
            left:26px;
            bottom:14px;
            margin:0;
            font-weight:700;
            color:#111;
        }
        .card .elapsed{
            position:absolute;
            right:26px;
            bottom:14px;
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
}

function finish_details_file() {
        print_to_file "
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