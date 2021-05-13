#!/usr/bin/env bash

set -eu

source ./set-pg-env.sh

echo
echo "Resetting Advisory Lock Function"
echo "= = ="

echo
echo "Restoring message-db gem to pristine (unmodified) state"
echo "- - -"
bundle pristine message-db
echo

echo "Reinstalling MessageDB functions"
echo "- - -"
echo

source ./set-pg-env.sh

./gems/bin/mdb-install-functions
