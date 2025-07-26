#!/usr/bin/env bash

cd "$(dirname "$BASH_SOURCE")"

exec nix build ../..#binaryninja.src -o ~/.binaryninja/src
