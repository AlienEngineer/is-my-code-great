declare -a TEST_FILES_CACHE=()
declare -a CODE_FILES_CACHE=()
TEST_FILES_CACHE_READY=false
CODE_FILES_CACHE_READY=false

_load_test_files_cache() {
  $TEST_FILES_CACHE_READY && return 0
  if [ "${LOCAL_RUN:-false}" = true ]; then
    mapfile -d '' -t TEST_FILES_CACHE < <(find "$DIR" -type f -name "$TEST_FILE_PATTERN" -print0)
  else
    mapfile -t TEST_FILES_CACHE < <(get_git_test_files)
  fi
  TEST_FILES_CACHE_READY=true
}

_load_code_files_cache() {
  $CODE_FILES_CACHE_READY && return 0
  if [ "${LOCAL_RUN:-false}" = true ]; then
    mapfile -d '' -t CODE_FILES_CACHE < <(find "$DIR" -type f -name "$CODE_FILE_PATTERN" -print0)
  else
    mapfile -t CODE_FILES_CACHE < <(get_git_files)
  fi
  CODE_FILES_CACHE_READY=true
}

get_test_files_to_analyse() {
  _load_test_files_cache
  printf '%s\n' "${TEST_FILES_CACHE[@]}"
}

get_files_to_analyse() {
  _load_code_files_cache
  printf '%s\n' "${CODE_FILES_CACHE[@]}"
}

function get_test_files_paginated() {
  local page_index="$1"
  local page_size="$2"

  _load_test_files_cache
  local total="${#TEST_FILES_CACHE[@]}"
  local offset=$(( page_index * page_size ))
  (( page_size > 0 )) || return 1 
  (( offset < total )) || return 1 
  (( offset >= 0 )) || offset=0
  local len="$page_size"
  (( offset + len <= total )) || len=$(( total - offset ))
  
  printf '%s\0' "${TEST_FILES_CACHE[@]:offset:len}"
}

function get_code_files_paginated() {
  local page_index="$1"
  local page_size="$2"

  _load_code_files_cache
  local total="${#CODE_FILES_CACHE[@]}"
  local offset=$(( page_index * page_size ))
  (( page_size > 0 )) || return 1 
  (( offset < total )) || return 1 
  (( offset >= 0 )) || offset=0
  local len="$page_size"
  (( offset + len <= total )) || len=$(( total - offset ))
  
  printf '%s\0' "${CODE_FILES_CACHE[@]:offset:len}"
}

function iterate_test_files() {
  local callback="${1:?}"; shift
  local page_size=200
  local page=0
  local -a files
  while :; do
    mapfile -d '' -t files < <(get_test_files_paginated "$page" "$page_size" 2>/dev/null || printf '')
    ((${#files[@]})) || break
    "$callback" "$@" files
    ((page++))
  done
}

function iterate_code_files() {
  local callback="${1:?}"; shift
  local page_size=200
  local page=0
  local -a files
  while :; do
    mapfile -d '' -t files < <(get_code_files_paginated "$page" "$page_size" 2>/dev/null || printf '')
    ((${#files[@]})) || break
    "$callback" "$@" files
    ((page++))
  done
}