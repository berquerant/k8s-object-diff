#!/bin/bash

status=0
fail_on_diff="$1"
shift
objdiff -o markdown "$@" >> "$GITHUB_STEP_SUMMARY"
status="$?"
echo "status=${status}" >> "$GITHUB_OUTPUT"
if [[ "$fail_on_diff" == "true" ]] ; then
    exit "$status"
fi
