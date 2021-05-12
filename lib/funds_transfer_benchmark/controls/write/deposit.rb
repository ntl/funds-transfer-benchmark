module FundsTransferBenchmark
  module Controls
    module Write
      module Deposit
        def self.call(account_id: nil, deposit_id: nil, amount: nil, session: nil)
          account_id ||= Account.id
          amount ||= Money.example

          AccountComponent::Commands::Deposit.(
            account_id: account_id,
            amount: amount,
            deposit_id: deposit_id,
            session: session
          )
        end
      end
    end
  end
end
