module FundsTransferBenchmark
  class Initiate
    include Initializer
    include Dependency
    include Settings::Setting
    include Log::Dependency

    setting :operations
    setting :entities
    setting :throughput_limit
    setting :advisory_lock_pool_size
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

      transfer_id_partitions = Controls::FundsTransfer::ID::Sequence.example(operations, partitions: advisory_lock_pool_size)

      start_time = clock.now

      partition_count = transfer_id_partitions.count

      transfer_partitions = partition_count.times.map do |partition|
        transfer_ids = transfer_id_partitions.fetch(partition)

        transfer_ids.map.with_index do |transfer_id, index|
          iteration = (index * partition_count) + partition

          withdrawal_id_increment = iteration
          withdrawal_account_id = Controls::Account::ID.example(withdrawal_id_increment, partition_count)

          deposit_id_increment = withdrawal_id_increment + 1
          deposit_account_id = Controls::Account::ID.example(deposit_id_increment, partition_count)

          TransferData.new(transfer_id, withdrawal_account_id, deposit_account_id, iteration)
        end
      end

      partition_count.times.map do |partition|
        fork do
          session = build_session

          transfers = transfer_partitions.fetch(partition)

          transfers.each.with_index do |transfer, index|
            cycle_start_time = clock.now

            logger.trace { "Issuing funds transfer command (Partition: #{partition}, Transfer ID: #{transfer.funds_transfer_id}, Withdrawal Account: #{transfer.withdrawal_account_id}, Deposit Account: #{transfer.deposit_account_id}, Iteration: #{transfer.iteration + 1}/#{operations})" }

            Controls::Write::Transfer.(id: transfer.funds_transfer_id, withdrawal_account_id: transfer.withdrawal_account_id, deposit_account_id: transfer.deposit_account_id, session: session)

            cycle_finish_time = clock.now

            if not index.zero?
              elapsed_time_seconds = cycle_finish_time - cycle_start_time

              wait_cycle(elapsed_time_seconds)
            end

            logger.debug { "Funds transfer command issued (Partition: #{partition}, Transfer ID: #{transfer.funds_transfer_id}, Withdrawal Account: #{transfer.withdrawal_account_id}, Deposit Account: #{transfer.deposit_account_id}, Iteration: #{transfer.iteration + 1}/#{operations}, Elapsed Time: %0.3fms" % (elapsed_time_seconds.to_i * 1_000) }
          end
        end
      end

      Process.waitall

      finish_time = clock.now

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
      cycle_time_seconds * advisory_lock_pool_size
    end

    def cycle_time_seconds
      @cycle_time ||= Rational(1, throughput_limit)
    end

    def build_session
      MessageStore::Postgres::Session.build
    end

    TransferData = Struct.new(:funds_transfer_id, :withdrawal_account_id, :deposit_account_id, :iteration)
  end
end
