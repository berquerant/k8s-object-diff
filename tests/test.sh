#!/bin/bash

log() {
    echo "$*" > /dev/stderr
}

do_test() {
    local -r _left="$1"
    local -r _right="$2"
    local -r _want_out_ids="$3"
    local -r _want_out_status="$4"

    local -r _got="$(mktemp)"
    local -r _exitstatus="$(mktemp)"
    echo 0 > "$_exitstatus"
    export GITHUB_OUTPUT="$_got"
    if ! ./entrypoint.sh "$_left" "$_right" ; then
        log "Failed to run entrypoint"
        echo 1 > "$_exitstatus"
    fi

    local -r _tmp_got="$(mktemp)"
    local -r _tmp_want="$(mktemp)"
    awk -F '=' '$1 == "ids" {print $2}' "$_got" > "$_tmp_got"
    echo "$_want_out_ids" > "$_tmp_want"
    if ! diff -u "$_tmp_want" "$_tmp_got" ; then
        log "Mismatched ids: want=$(cat "$_tmp_want") got=$(cat "$_tmp_got")"
        echo 1 > "$_exitstatus"
    fi
    awk -F '=' '$1 == "status" {print $2}' "$_got" > "$_tmp_got"
    echo "$_want_out_status" > "$_tmp_want"
    if ! diff -u "$_tmp_want" "$_tmp_got" ; then
        log "Mismatched status: want=$(cat "$_tmp_want") got=$(cat "$_tmp_got")"
        echo 1 > "$_exitstatus"
    fi

    return "$(cat "$_exitstatus")"
}

list_testcases() {
    find tests/cases -type f -name "*.yml" | sort
}

run_test() {
    local -r _testcase="$1"
    local -r _desc="$(yq '.desc' "$_testcase")"
    log "START ${_testcase} | ${_desc} ------"
    local _ret=0
    do_test "tests/data/$(yq '.left' "$_testcase")" \
            "tests/data/$(yq '.right' "$_testcase")" \
            "$(yq '.want_out_ids' "$_testcase")" \
            "$(yq '.want_out_status' "$_testcase")"
    _ret="$?"
    log "END ${_testcase} ------"
    echo "EXIT ${_ret} ${_testcase} | ${_desc}"
    return "$_ret"
}

readonly result="$(mktemp)"
readonly ret="$(mktemp)"
echo 0 > "$ret"

set +e
log "START testcases ------"
list_testcases | while read -r testcase ; do
    if ! run_test "$testcase" ; then
        echo 1 > "$ret"
    fi
done | tee "$result"
log "END testcases ------"
log "RESULT ------"
cat "$result" | grep "^EXIT"
exit "$(cat "$ret")"
