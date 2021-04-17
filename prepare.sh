#!/usr/bin/env bash

set -eu -o pipefail

echo
echo "Preparing Measurement"
echo "= = ="

recreate_message_db=$(jq '.recreateMessageDB' < settings/benchmark.json)

if [ "$recreate_message_db" = "true" ]; then
  ./recreate-db.sh
else
  ./clear-db.sh
fi

ruby --disable-gems ./script/prepare.rb
