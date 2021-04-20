module FundsTransferBenchmark
  module Controls
    module Account
      def self.id
        ID.example
      end

      module ID
        def self.example(offset=nil, offset_limit: nil)
          Controls::ID.example(offset, offset_limit: offset_limit)
        end

        module Withdrawal
          def self.example
            ID.example(offset)
          end

          def self.offset
            1
          end
        end

        module Deposit
          def self.example
            ID.example(offset)
          end

          def self.offset
            2
          end
        end
      end
    end
  end
end
