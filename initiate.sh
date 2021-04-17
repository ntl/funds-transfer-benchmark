#!/usr/bin/env bash

set -eu -o pipefail

echo
echo "Initiating Benchmark"
echo "= = ="

ruby --disable-gems ./script/initiate.rb
