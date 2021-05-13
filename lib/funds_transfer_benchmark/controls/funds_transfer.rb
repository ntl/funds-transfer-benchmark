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

        module Sequence
          module Group
            def self.example(count: nil, size: nil)
              Controls::ID::Sequence::Group.example(count: count, size: size, prefix: prefix)
            end

            def self.prefix
              ID.prefix
            end
          end
        end
      end
    end
  end
end
