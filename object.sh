#!/bin/bash

set -e -o pipefail

readonly default_diff="diff -u"

diff_cmd() {
    ${DIFF:-${default_diff}} "$@"
}

touchd() {
    mkdir -p "$1"
    echo "$1"
}

touchf() {
    mkdir -p "$(dirname "$1")"
    touch "$1"
    echo "$1"
}

readonly rootd="$(mktemp -d)"
readonly leftd="$(touchd "${rootd}/left")"
readonly rightd="$(touchd "${rootd}/right")"
readonly empty="$(mktemp)"

documentd() {
    touchd "$1/documents"
}

indexf() {
    touchf "$1/index"
}

manifest2id() {
    yq '(.apiVersion)+">"+(.kind)+">"+(.metadata.namespace // "")+">"+(.metadata.name)' -r | grep -v '^-'
}

divide_manifests() {
    local -r _manifest="$1"
    local -r _dir="$2"

    local _index=0
    local -r _index_file="$(indexf "$_dir")"

    while true ; do
        local _file
        _file="$(documentd "$_dir")/${_index}"
        yq --prettyPrint "select(documentIndex == ${_index}) | sort_keys(..)" "$_manifest" > "$_file"
        if [ ! -s "$_file" ] ; then
            break
        fi
        local _id
        set +e
        _id="$(manifest2id < "$_file")"
        set -e
        if [ -n "$_id" ] ; then
            echo "${_id} ${_file}" >> "$_index_file"
        fi
        _index="$((_index + 1))"
    done
}

prepare_manifests() {
    divide_manifests "$1" "$leftd"
    divide_manifests "$2" "$rightd"
}

uniq_ids() {
    awk '{print $1}' "$(indexf "$1")" | sort
}

all_uniq_ids() {
    (uniq_ids "$leftd" ; uniq_ids "$rightd") | sort -u
}

find_manifest() {
    local -r _found="$(awk -v x="$1" '$1==x{print $2}' "$2")"
    if [ -n "$_found" ] ; then
        echo "$_found"
    else
        echo "$empty"
    fi
}

__diff() {
    local -r _res="$(mktemp)"
    diff_cmd "$1" "$2" > "$_res"
    local -r _ret="$?"

    awk -v left="$1" -v right="$2" '{
  if (($1 == "---" || $1 == "+++") && ($2 == left || $2 == right)) {
    print $1, $2
  } else {
    print
  }
}' "$_res"
    return "$_ret"
}

diff_sed() {
    local _diff_result
    _diff_result="$(mktemp)"
    __diff "$1" "$2" > "$_diff_result"
    local -r _diff_ret="$?"
    shift 2
    sed "$@" < "$_diff_result"
    return "$_diff_ret"
}

diff_object_by_id() {
    local -r _left="$1"
    local -r _right="$2"
    local -r _id="$3"

    local -r _lfile="$(find_manifest "$_id" "$(indexf "$leftd")")"
    local -r _rfile="$(find_manifest "$_id" "$(indexf "$rightd")")"

    local -r _left_name="${_left} ${_id}"
    local -r _right_name="${_right} ${_id}"

    diff_sed "$_lfile" "$_rfile" \
             -e "s|${_lfile}|${_left_name}|" \
             -e "s|${_rfile}|${_right_name}|"
}

diff_object() {
    local -r _res="$(mktemp)"
    echo 0 > "$_res"
    set +e
    all_uniq_ids | while read -r _id ; do
        local _r
        diff_object_by_id "$1" "$2" "$_id"
        _r=$?
        if [ "$_r" -ne 0 ] ; then
            echo "$_r" > "$_res"
        fi
    done
    return "$(cat "$_res")"
}

main() {
    local -r _left="$1"
    local -r _right="$2"
    prepare_manifests "$_left" "$_right"
    diff_object "$_left" "$_right"
}

main "$@"
