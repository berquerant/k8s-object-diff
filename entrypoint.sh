#!/bin/bash

readonly d="$(cd "$(dirname "$0")" || exit 2; pwd)"

status=0
objdiff --color "$@"
status="$?"
echo "status=${status}" >> "$GITHUB_OUTPUT"
