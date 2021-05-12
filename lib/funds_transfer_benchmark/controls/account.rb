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
        def self.example(increment=nil, partition_count=nil, seed: nil)
          Controls::ID.example(increment, partition_count, prefix: prefix, seed: seed)
        end

        def self.prefix
          0x00000000
        end

        module Sequence
          def self.example(count=nil, partitions: nil)
            Controls::ID::Sequence.example(count, prefix: prefix, partitions: partitions)
          end

          def self.prefix
            ID.prefix
          end
        end
      end
    end
  end
end
