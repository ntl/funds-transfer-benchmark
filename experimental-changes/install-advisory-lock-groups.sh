#!/usr/bin/env bash

set -eu

acquire_lock_sql=./gems/ruby/*/gems/message-db-*/database/functions/acquire-lock.sql

echo
echo "Installing Advisory Lock Groups"
echo "= = ="

advisoryLockGroupSize=${ADVISORY_LOCK_GROUP_SIZE:-$(jq '.advisoryLockGroupSize' < settings/benchmark.json)}
echo "Advisory Lock Group Size: $advisoryLockGroupSize"

if [ ! -s $acquire_lock_sql ]; then
  echo "Message DB is not installed under ./gems; install-gems.sh must be run first"
  exit 1
fi

echo
echo "Restoring message-db gem to pristine (unmodified) state"
echo "- - -"
bundle pristine message-db
echo

echo "Editing database/functions/acquire_lock.sql"
echo "- - -"
ed --quiet $acquire_lock_sql <<ED
/^DECLARE/a
  _advisory_lock_group_size integer;
  _cardinal_id varchar;
  _cardinal_id_hash bigint;
.
/^BEGIN/a
  _advisory_lock_group_size := $advisoryLockGroupSize;
  _cardinal_id := cardinal_id(acquire_lock.stream_name);
  _cardinal_id_hash := hash_64(_cardinal_id);
.
/PERFORM pg_advisory_xact_lock(_category_name_hash)/ \
  s/_category_name_hash/(& << 8) | MOD(_cardinal_id_hash, _advisory_lock_group_size)/
w
%p
ED

echo "- - -"
echo "(done)"
echo
