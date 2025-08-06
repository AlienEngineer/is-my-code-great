#!/usr/bin/env bash

  declare SEVERITY=()
  declare COMMAND=()
  declare VALIDATION=()
  declare TITLE=()

  function register_validation() {
    local check_name="$1"
    SEVERITY+=([$check_name]="$2")
    COMMAND+=([$check_name]="$(eval "$3")")
    TITLE+=([$check_name]="$4")
    VALIDATION+=("$check_name")
  }

function get_validations() {
    printf "%s\n" "${VALIDATION[@]}"
}

function get_severity() {
  local check_name="$1"
  echo "${SEVERITY[$check_name]}"
}

function get_title() {
  local check_name="$1"
  echo "${TITLE[$check_name]}"
}

function get_result() {
    local check_name="$1"
    echo "${COMMAND[$check_name]}"
}