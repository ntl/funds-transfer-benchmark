#!/usr/bin/env bash

set -eu

source set-pg-env.sh

ruby --disable-gems ./script/print_results.rb
