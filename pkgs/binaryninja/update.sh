#!/usr/bin/env bash
set -eu

cd "$(dirname "$BASH_SOURCE")"

curl https://binary.ninja/js/hashes.js -o tmp.json
jq --tab --sort-keys <tmp.json >hashes.json
rm tmp.json
