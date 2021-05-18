#!/usr/bin/env bash

set -eu

projects_home=${PROJECTS_HOME}

echo
echo "Removing logging from Eventide libraries"
echo "= = ="
echo

account_component_dir=$projects_home/account-component
funds_transfer_component_dir=$projects_home/funds-transfer-component

remove_logging() {
  rb_file=$1

  if [[ "$rb_file" =~ "lib/messaging/write.rb" ]]; then
    echo "Skipping $rb_file"
    return
  fi
  pattern="^[[:blank:]]*(logger\.)"

  cmd="sed -i $rb_file -E -e \"s/^[[:blank:]]*((handler_)?logger\.(trace|debug|info|warn|error|fatal))/false and \1/\""
  eval "$cmd"
}

remove_logging_project() {
  for rb_file in $(find ./gems/ruby -wholename "./gems/ruby/*/gems/evt-*" -type f -name "*.rb" | grep -v controls); do
    remove_logging $rb_file
  done
}

for component_dir in . $account_component_dir $funds_transfer_component_dir; do
  echo "Removing logging from $component_dir"
  echo "- - -"
  echo

  pushd $component_dir

  remove_logging_project

  popd
done
