module FundsTransferBenchmark
  module Controls
    module FundsTransfer
      module ID
        def self.example(increment=nil, seed: nil)
          Controls::ID.example(increment, prefix: prefix, seed: seed)
        end

        def self.prefix
          0x11111111
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
