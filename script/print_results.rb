#!/usr/bin/env ruby

require_relative '../init'

FundsTransferBenchmark::Measurements::Transfers.(ENV['DATABASE_NAME'])
