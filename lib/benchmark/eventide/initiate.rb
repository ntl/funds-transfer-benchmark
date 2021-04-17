module Benchmark
  module Eventide
    class Initiate
      include Initializer
      include Dependency
      include Settings::Setting

      include GetPartition::Dependency
      include Log::Dependency

      setting :operations
      setting :entities
      setting :throughput_limit
      setting :write_partitions
      setting :force

      dependency :clock, Clock::UTC

      def self.build(settings: nil)
        instance = new
        Settings.set(instance, settings: settings)
        Clock::UTC.configure(instance)
        instance
      end

      def self.call(settings: nil)
        instance = build(settings: settings)
        instance.()
      end

      def call
        logger.trace { "Initiating benchmark (Transfers: #{operations}, Accounts: #{entities || operations})" }

        assure_not_initiated

        transfer_amount = 1

        transfers = operations.times.cycle.first(operations + 1).each_cons(2)

        partitions = Hash.new do |hsh, partition|
          hsh[partition] = []
        end

        transfers.each_with_index do |(withdrawal_index, deposit_index), index|
          funds_transfer_id = Controls::FundsTransfer::ID.example(withdrawal_index)
          withdrawal_account_id = Controls::Account::ID.example(withdrawal_index, offset_limit: entities)
          deposit_account_id = Controls::Account::ID.example(deposit_index, offset_limit: entities)

          transfer_data = {
            :id => funds_transfer_id,
            :withdrawal_account_id => withdrawal_account_id,
            :deposit_account_id => deposit_account_id
          }

          stream_name = Messaging::StreamName.command_stream_name('fundsTransfer', funds_transfer_id)
          partition = get_partition.advisory_lock(stream_name)

          partitions[partition] << [funds_transfer_id, withdrawal_account_id, deposit_account_id, index]
        end

        start_time = Clock.now

        write_partitions.times.map do |partition|
          fork do
            session ||= build_session

            messages = partitions.fetch(partition)

            messages.each do |funds_transfer_id, withdrawal_account_id, deposit_account_id, index|
              cycle_start_time = Clock.now

              logger.trace { "Issuing funds transfer command (Partition: #{partition}, Transfer ID: #{funds_transfer_id}, Amount: #{transfer_amount}, Withdrawal Account: #{withdrawal_account_id}, Deposit Account: #{deposit_account_id}, Iteration: #{index + 1}/#{operations})" }

              Controls::Write::Transfer.(id: funds_transfer_id, amount: transfer_amount, withdrawal_account_id: withdrawal_account_id, deposit_account_id: deposit_account_id, session: session)

              logger.debug { "Funds transfer command issued (Partition: #{partition}, Transfer ID: #{funds_transfer_id}, Amount: #{transfer_amount}, Withdrawal Account: #{withdrawal_account_id}, Deposit Account: #{deposit_account_id}, Iteration: #{index + 1}/#{operations})" }

              cycle_finish_time = Clock.now

              if not index.zero?
                elapsed_time_seconds = cycle_finish_time - cycle_start_time

                wait_cycle(elapsed_time_seconds)
              end
            end
          end
        end

        Process.waitall

        finish_time = Clock.now

        elapsed_time = finish_time - start_time
        elapsed_time_text = "%0.3fs" % elapsed_time
        throughput_text = "%0.3f msg/s" % Rational(operations, elapsed_time)

        logger.info { "Benchmark initiated (Transfers: #{operations}, Elapsed Time: #{elapsed_time_text}, Throughput: #{throughput_text}, Accounts: #{entities || operations})" }
      end

      def wait_cycle(elapsed_time_seconds)
        wait_time_seconds = partition_cycle_time_seconds - elapsed_time_seconds

        logger.trace { "Wait cycle starting (Cycle Time: %0.3fms, Elapsed Time: %0.3fms, Wait Time: %0.3fms)" % [cycle_time_seconds * 1000, elapsed_time_seconds * 1000, wait_time_seconds * 1000] }

        if wait_time_seconds > 0
          sleep(wait_time_seconds)

          logger.debug { "Wait cycle complete (Cycle Time: %0.3fms, Elapsed Time: %0.3fms, Wait Time: %0.3fms)" % [cycle_time_seconds * 1000, elapsed_time_seconds * 1000, wait_time_seconds * 1000] }
        else
          logger.trace { "No wait cycle (Cycle Time: %0.3fms, Elapsed Time: %0.3fms, Wait Time: %0.3fms)" % [cycle_time_seconds * 1000, elapsed_time_seconds * 1000, wait_time_seconds * 1000] }
        end
      end

      def assure_not_initiated(session=nil)
        session ||= build_session

        database_name = session.dbname

        funds_transfer_commands = MessageStore::Postgres::Get::Category.("fundsTransfer:command", session: session)

        already_initiated = funds_transfer_commands.any?

        if already_initiated
          message = "A run has already been initiated (Force: #{force}, Database: #{database_name})"
          if force
            logger.warn(message)
          else
            logger.error(message)
            exit 1
          end
        end
      end

      def partition_cycle_time_seconds
        cycle_time_seconds * write_partitions
      end

      def cycle_time_seconds
        @cycle_time ||= Rational(1, throughput_limit)
      end

      def build_session
        MessageStore::Postgres::Session.build
      end
    end
  end
end
