#!/bin/bash

status=0
objdiff --color "$@"
status="$?"
echo "status=${status}" >> "$GITHUB_OUTPUT"
