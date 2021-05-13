#!/usr/bin/env bash

set -eu -o pipefail

source ./set-pg-env.sh

./gems/bin/mdb-clear-messages
