#!/usr/bin/env bash

set -eu

echo "Installing gems to ./gems"
echo '= = ='

bundle config set --local path gems

bundle install --standalone

bundle binstubs --path ./gems/bin --all

echo '- - -'
echo '(done)'
echo
