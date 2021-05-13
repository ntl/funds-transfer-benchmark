#!/usr/bin/env ruby

ENV['LOG_TAGS'] ||= '_untagged,-data,messaging,ignored'

require_relative '../init'

require 'component_host'

module FundsTransferComponent
  module StartConsumerGroup
    def self.call
      consumer_start_attrs = FundsTransferBenchmark::ConsumerGroup.start_attrs

      Consumers::Commands.start('fundsTransfer:command', **consumer_start_attrs)
      Consumers::Events.start('fundsTransfer', **consumer_start_attrs)

      consumer_start_attrs[:identifier] = "fundsTransfer-#{consumer_start_attrs}"
      Consumers::Account::Events.start('account', correlation: 'fundsTransfer', **consumer_start_attrs)
    end
  end
end

ComponentHost.start('funds-transfer-component') do |host|
  host.register(FundsTransferComponent::StartConsumerGroup)
end
