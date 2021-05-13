#!/usr/bin/env ruby

ENV['LOG_TAGS'] ||= '_untagged,-data,messaging,ignored'

require_relative '../init'

require 'funds_transfer_component'

require 'component_host'

ComponentHost.start('funds-transfer-component') do |host|
  host.register(FundsTransferComponent::Start)
end
