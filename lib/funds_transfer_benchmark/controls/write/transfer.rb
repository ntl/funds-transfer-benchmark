module FundsTransferBenchmark
  module Controls
    module Write
      module Transfer
        def self.call(id: nil, withdrawal_account_id: nil, deposit_account_id: nil, amount: nil, session: nil)
          withdrawal_account_id ||= Account::ID::Withdrawal.example
          deposit_account_id ||= Account::ID::Deposit.example
          amount ||= Money.example

          FundsTransferComponent::Commands::Transfer.(
            withdrawal_account_id: withdrawal_account_id,
            deposit_account_id: deposit_account_id,
            amount: amount,
            funds_transfer_id: id,
            session: session
          )
        end
      end
    end
  end
end
