#!/usr/bin/env ruby

ENV['LOG_LEVEL'] ||= 'debug'

require_relative '../init'

FundsTransferBenchmark::Prepare.()
