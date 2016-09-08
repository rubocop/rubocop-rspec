#!/bin/bash

# Taken from dkubb/dockerfiles: https://git.io/viGZZ
#
# Reference:
# http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# http://kvz.io/blog/2013/11/21/bash-best-practices/
# http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -o errexit    # Exit when an expression fails
set -o pipefail   # Exit when a command in a pipeline fails
set -o nounset    # Exit when an undefined variable is used
set -o noglob     # Disable shell globbing
set -o noclobber  # Disable automatic file overwriting

IFS=$'\n\t'  # Set default field separator to not split on spaces
