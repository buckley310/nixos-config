#!/usr/bin/env bash

cd "$(dirname "$BASH_SOURCE")"

curl https://binary.ninja/js/hashes.js -o hashes.json
