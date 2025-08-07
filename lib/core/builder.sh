#!]

  declare -a SEVERITY COMMAND TITLE VALIDATION

  function register_validation() {
    local check_name="$1"
    SEVERITY+=("$2")
    COMMAND+=("$(eval "$3")")
    TITLE+=("$4")
    VALIDATION+=("$check_name")
  }

function get_validations() {
    printf "%s\n" "${VALIDATION[@]}"
}

function get_index() {
  local check_name="$1"
  for i in "${!VALIDATION[@]}"; do
    [[ "${VALIDATION[i]}" == "$check_name" ]] && echo "$i" && return
  done
  return 1
}

function get_severity() {
  local index
  index=$(get_index "$1")
  echo "${SEVERITY[$index]}"
}

function get_title() {
  local index
  index=$(get_index "$1")
  echo "${TITLE[$index]}"
}

function get_result() {
  local index
  index=$(get_index "$1")
  echo "${COMMAND[$index]}"
}

function get_total_issues() {
  local total=0
  for result in "${COMMAND[@]}"; do
    total=$((total + result))
  done
  echo "$total"
}

function print_validations() {
  local totalIssues=$(get_total_issues)
  printf "%-40s %4d\n\n" "Total Issues Found:" "$totalIssues"

  printf "%-40s %4s %-10s\n" "Issues on Tests:" "#" "Severity"
  get_validations | while read -r validation; do
    printf "%-40s %4d %-10s\n" \
      "$(get_title "$validation")" \
      "$(get_result "$validation")" \
      "$(get_severity "$validation")"
  done
}