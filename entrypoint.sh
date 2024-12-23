#!/bin/bash

readonly d="$(cd "$(dirname "$0")" || exit 2; pwd)"

readonly res="$(mktemp)"
status=0
"${d}/object.sh" "$@" > "$res"
status="$?"

cat "$res"
echo "status=${status}" >> "$GITHUB_OUTPUT"

readonly ids="$(mktemp)"
awk '$1 == "---" {print $3}' < "$res" | xargs > "$ids"

echo "ids=$(cat "$ids")" >> "$GITHUB_OUTPUT"
