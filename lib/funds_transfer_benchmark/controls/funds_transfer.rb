module FundsTransferBenchmark
  module Controls
    module FundsTransfer
      def self.id
        ID.example
      end

      module ID
        def self.example(increment=nil, group_size: nil)
          Controls::ID::GroupMember.example(increment, prefix: prefix, group_size: group_size)
        end

        def self.prefix
          0x11111111
        end
      end
    end
  end
end
