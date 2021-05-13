module FundsTransferBenchmark
  class Initiate
    include Initializer
    include Dependency
    include Settings::Setting
    include Log::Dependency

    setting :operations
    setting :entities
    setting :throughput_limit
    setting :advisory_lock_group_size
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

      transfer_ids_by_group_member = Controls::FundsTransfer::ID::Sequence::Group.example(count: operations, size: advisory_lock_group_size)

      transfers_by_group_member = transfer_ids_by_group_member.map.with_index do |transfer_ids, group_member|
        transfer_ids.map.with_index do |transfer_id, index|
          iteration = (index * advisory_lock_group_size) + group_member

          withdrawal_id_increment = iteration
          withdrawal_account_id = Controls::Account::ID.example(withdrawal_id_increment, increment_limit: entities, group_size: advisory_lock_group_size)

          deposit_id_increment = iteration + 1
          deposit_account_id = Controls::Account::ID.example(deposit_id_increment, increment_limit: entities, group_size: advisory_lock_group_size)

          Transfer.new(transfer_id, withdrawal_account_id, deposit_account_id, iteration)
        end
      end

      start_time = clock.now

      transfers_by_group_member.map.with_index do |transfers, group_member|
        fork do
          session = build_session

          transfers.each.with_index do |transfer, index|
            cycle_start_time = clock.now

            logger.trace { "Issuing funds transfer command (Group Member: #{group_member}, Transfer ID: #{transfer.funds_transfer_id}, Withdrawal Account: #{transfer.withdrawal_account_id}, Deposit Account: #{transfer.deposit_account_id}, Iteration: #{transfer.iteration + 1}/#{operations})" }

            transfer.(session)

            cycle_finish_time = clock.now

            elapsed_time_seconds = cycle_finish_time - cycle_start_time

            if not index.zero?
              wait_cycle(elapsed_time_seconds)
            end

            logger.debug { "Funds transfer command issued (Group Member: #{group_member}, Transfer ID: #{transfer.funds_transfer_id}, Withdrawal Account: #{transfer.withdrawal_account_id}, Deposit Account: #{transfer.deposit_account_id}, Iteration: #{transfer.iteration + 1}/#{operations}, Elapsed Time: %0.3fms" % (elapsed_time_seconds * 1_000) }
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
      process_count = advisory_lock_group_size
      per_process_cycle_time_seconds = cycle_time_seconds * process_count

      wait_time_seconds = per_process_cycle_time_seconds - elapsed_time_seconds

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

    def cycle_time_seconds
      @cycle_time ||= Rational(1, throughput_limit)
    end

    def build_session
      MessageStore::Postgres::Session.build
    end

    Transfer = Struct.new(:funds_transfer_id, :withdrawal_account_id, :deposit_account_id, :iteration) do
      def call(session)
        Controls::Write::Transfer.(
          id: funds_transfer_id,
          withdrawal_account_id: withdrawal_account_id,
          deposit_account_id: deposit_account_id,
          session: session
        )
      end
    end
  end
end
