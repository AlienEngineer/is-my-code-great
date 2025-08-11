# is-my-code-great
Command-line tool to verify arbitrary aspects about code.

## for windows users
[brew for windows](https://docs.brew.sh/Installation#linux-or-windows-10-subsystem-for-linux)

## install

`brew tap AlienEngineer/tap`

`brew install is-my-code-great`


## Usage
Navigate to the root folder you would like to evaluate and execute the following command, alternativelly the path can be specified.
```sh
is-my-code-great <path>
is-my-code-great --help

# for quick check againt main branch:
is-my-code-great -g

# for quick check againt specific branch:
is-my-code-great -b master
```

## update
`brew update`

`brew upgrade is-my-code-great`

## add new validations
To add a new validations it's as simple as adding a new <filename>.sh file to the lib/validations folder using the following template:

```
#!/usr/bin/env bash

# implementation for the new validation
# $DIR - this variable can be used to fetch which directory we are working on.
# checkout the core folder for functions that makes it easier to find text on files.
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

