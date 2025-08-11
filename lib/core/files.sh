
get_files_to_analyse() {
  if [ "$LOCAL_RUN" = true ]; then
    find "$DIR" -type f -name "$TEST_FILE_PATTERN"
  else
    get_git_files
  fi
}