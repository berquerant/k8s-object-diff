#!/bin/bash

set -ex -o pipefail

apt-get update
apt-get install -y wget
rm -rf /var/lib/apt/lists/*

readonly yq_version="${YQ_VERSION:-v4.44.6}"
readonly yq_binary="${YQ_BINARY:-yq_linux_amd64}"
wget "https://github.com/mikefarah/yq/releases/download/${yq_version}/${yq_binary}.tar.gz" \
     -q -O - | tar xz
mv "${yq_binary}" /usr/bin/yq
