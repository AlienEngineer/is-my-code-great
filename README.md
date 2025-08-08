# is-my-code-great
Command-line tool to verify arbitrary aspects about code.

## for windows users
[brew for windows](https://docs.brew.sh/Installation#linux-or-windows-10-subsystem-for-linux)

## install

`brew tap AlienEngineer/tap`

`brew install is-my-code-great`

## update
`brew update`

`brew upgrade is-my-code-great`

## add new validations
To add a new validations it's as simple as adding a new <filename>.sh file to the lib/validations folder using the following template:

```
#!/usr/bin/env bash

SCRIPT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
source "$SCRIPT_ROOT/lib/core/text-finders.sh"
source "$SCRIPT_ROOT/lib/core/builder.sh"

# implementation for the new validation
# $dir - this variable can be used to fetch which directory we are working on.
# checkout the text-finders.sh for functions that makes it easier to find text on files.
function my_custom_validaton() {
 echo -1
}

# registers the new validation
register_validation \
    "<unique_key>" \
    "<severity>" \ # LOW, HIGH, CRITICAL
    "my_custom_validaton" \
    "<description>:"
```

## Usage
Navigate to the root folder you would like to evaluate and execute the following command
```sh
is-my-code-great
```
