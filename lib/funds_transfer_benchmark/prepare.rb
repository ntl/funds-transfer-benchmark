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
      accounts = entities || operations

      logger.trace { "Preparing benchmark (Transfers: #{operations}, Accounts: #{accounts})" }

      money_increment = Controls::Money.example
      deposit_amount = Rational(operations, accounts) * money_increment

      increment_limit = accounts * advisory_lock_group_size

      accounts.times do |increment|
        id_increment = id_increment(increment)
        account_id = Controls::Account::ID.example(id_increment, increment_limit: increment_limit, group_size: advisory_lock_group_size)

        logger.trace { "Issuing initial deposit (Account ID: #{account_id}, Amount: #{deposit_amount}, Iteration: #{increment + 1}/#{accounts})" }

        Controls::Write::Deposit.(account_id: account_id, amount: deposit_amount, session: session)

        logger.debug { "Initial deposit issued (Account ID: #{account_id}, Amount: #{deposit_amount}, Iteration: #{increment + 1}/#{accounts})" }
      end

      logger.info { "Benchmark prepared (Transfers: #{operations}, Accounts: #{accounts})" }
    end

    def id_increment(increment)
      if worst_case
        increment * advisory_lock_group_size
      else
        increment
      end
    end

    def session
      @session ||= MessageStore::Postgres::Session.build
    end
  end
end
