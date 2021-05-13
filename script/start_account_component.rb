#!/usr/bin/env ruby

ENV['LOG_TAGS'] ||= '_untagged,-data,messaging,ignored'

require_relative '../init'

require 'account_component'

require 'component_host'

ComponentHost.start('account-component') do |host|
  host.register(AccountComponent::Start)
end
