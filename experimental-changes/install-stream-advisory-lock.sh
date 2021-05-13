#!/usr/bin/env bash

set -eu

acquire_lock_sql=./gems/ruby/*/gems/message-db-*/database/functions/acquire-lock.sql

echo
echo "Installing Stream Advisory Lock"
echo "= = ="

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
  _stream_name_hash bigint;
.
/^BEGIN/a
  _stream_name_hash := hash_64(acquire_lock.stream_name);
.
/PERFORM pg_advisory_xact_lock(_category_name_hash)/ \
  s/_category_name_hash/_stream_name_hash/
w
%p
ED

echo
echo "Reinstalling MessageDB functions"
echo "- - -"
echo

source ./set-pg-env.sh

./gems/bin/mdb-install-functions

echo "- - -"
echo "(done)"
echo
