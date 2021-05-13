module FundsTransferBenchmark
  module Controls
    module Account
      def self.id
        ID.example
      end

      module Deposit
        def self.id(increment=nil)
          ID.example(increment, prefix: id_prefix)
        end

        def self.id_prefix
          0x22222222
        end
      end

      module Withdrawal
        def self.id(increment=nil)
          ID.example(increment, prefix: id_prefix)
        end

        def self.id_prefix
          0x33333333
        end
      end

      module ID
        def self.example(increment=nil, increment_limit: nil, group_size: nil)
          increment ||= 0

          if not increment_limit.nil?
            increment %= increment_limit
          end

          Controls::ID::GroupMember.example(increment, prefix: prefix, group_size: group_size)
        end

        def self.prefix
          0x00000000
        end
      end
    end
  end
end
