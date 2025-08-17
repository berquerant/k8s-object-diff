#!/bin/bash

status=0
fail_on_diff="$1"
shift
objdiff --color "$@"
status="$?"
echo "status=${status}" >> "$GITHUB_OUTPUT"
if [[ "$fail_on_diff" == "true" ]] ; then
    exit "$status"
fi
