module FundsTransferBenchmark
  class Prepare
    include Initializer
    include Settings::Setting

    include Log::Dependency

    setting :operations
    setting :entities
    setting :advisory_lock_group_size

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
      logger.trace { "Preparing benchmark (Transfers: #{operations}, Accounts: #{entities || operations})" }

      money_increment = Controls::Money.example
      standard_account_amount = operations * money_increment
      initial_account_amount = standard_account_amount + money_increment

      entities.times do |increment|
        account_id = Controls::Account::ID.example(increment, increment_limit: entities, group_size: advisory_lock_group_size)

        if increment.zero?
          amount = initial_account_amount
        else
          amount = standard_account_amount
        end

        logger.trace { "Issuing initial deposit (Account ID: #{account_id}, Amount: #{amount}, Iteration: #{increment + 1}/#{entities || operations})" }

        Controls::Write::Deposit.(account_id: account_id, amount: amount, session: session)

        logger.debug { "Initial deposit issued (Account ID: #{account_id}, Amount: #{amount}, Iteration: #{increment + 1}/#{entities || operations})" }
      end

      logger.info { "Benchmark prepared (Transfers: #{operations}, Accounts: #{entities || operations})" }
    end

    def session
      @session ||= MessageStore::Postgres::Session.build
    end
  end
end
