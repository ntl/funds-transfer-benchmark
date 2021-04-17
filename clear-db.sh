#!/usr/bin/env bash

set -eu -o pipefail

./set-pg-env.sh

./gems/bin/mdb-clear-messages
