#!/usr/bin/env ruby

ENV['LOG_TAGS'] ||= '_untagged,-data,messaging,ignored'

require_relative '../init'

require 'component_host'

module AccountComponent
  module StartConsumerGroup
    def self.call
      consumer_start_attrs = FundsTransferBenchmark::ConsumerGroup.start_attrs

      Consumers::Commands.start('account:command', **consumer_start_attrs)
      Consumers::Commands::Transactions.start('accountTransaction', **consumer_start_attrs)
    end
  end
end

ComponentHost.start('account-component') do |host|
  host.register(AccountComponent::StartConsumerGroup)
end
