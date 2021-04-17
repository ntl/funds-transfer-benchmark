#!/usr/bin/env bash

set -eu -o pipefail

echo
echo "Setting Postgres environment variables"
echo "= = ="
echo

settings_file=${1:-./settings/message_store_postgres.json}

if [ ! -s $settings_file ]; then
  echo "Error: settings file '$settings_file' not found; see '$settings_file.example' for reference"
  echo
  exit 1
fi

default_pg_database=$(jq --raw-output '.dbname' < $settings_file)
echo "DATABASE_NAME: ${DATABASE_NAME:-$default_pg_database (from settings file)}"
export DATABASE_NAME=${DATABASE_NAME:-$default_pg_database}
echo
