#!/usr/bin/env bash

set -eu

export LOG_TAGS='_untagged,-data,-handle,messaging,ignored'

ruby --disable-gems ./script/start_account_component.rb $@
