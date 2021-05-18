module FundsTransferBenchmark
  class Prepare
    include Initializer
    include Settings::Setting

    include Log::Dependency

    setting :operations
    setting :entities
    setting :advisory_lock_group_size
    setting :worst_case

    def self.build(settings: nil)
      instance = new
      Settings.set(instance, settings: settings)
      instance
    end

    def self.call(settings: nil)
      instance = build(settings: settings)
      instance.()
    end

    def call
      logger.trace { "Preparing benchmark (Transfers: #{operations}, Accounts: #{accounts})" }

      money_increment = Controls::Money.example
      deposit_amount = Rational(operations, accounts) * money_increment

      get_advisory_lock = AdvisoryLock::Get.build
      get_consumer_group_member = ConsumerGroup::GetMember.build

      accounts.times do |increment|
        id_increment = id_increment(increment)
        account_id = Controls::Account::ID.example(id_increment, increment_limit: increment_limit, group_size: advisory_lock_group_size)

        advisory_lock_member = get_advisory_lock.group_member(account_id)
        consumer_group_member = get_consumer_group_member.cardinal_id(account_id)

        logger.trace { "Issuing initial deposit (Account ID: #{account_id}, Amount: #{deposit_amount}, Iteration: #{increment + 1}/#{accounts}, Advisory Lock Member: #{advisory_lock_member}, Consumer Group Member: #{consumer_group_member})" }

        Controls::Write::Deposit.(account_id: account_id, amount: deposit_amount, session: session)

        logger.debug { "Initial deposit issued (Account ID: #{account_id}, Amount: #{deposit_amount}, Iteration: #{increment + 1}/#{accounts}, Advisory Lock Member: #{advisory_lock_member}, Consumer Group Member: #{consumer_group_member})" }
      end

      logger.info { "Benchmark prepared (Transfers: #{operations}, Accounts: #{accounts})" }
    end

    def accounts
      entities || operations
    end

    def id_increment(increment)
      if worst_case
        increment * advisory_lock_group_size
      else
        increment
      end
    end

    def increment_limit
      if worst_case
        accounts * advisory_lock_group_size
      else
        accounts
      end
    end

    def session
      @session ||= MessageStore::Postgres::Session.build
    end
  end
end
