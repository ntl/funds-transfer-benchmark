module FundsTransferBenchmark
  module Controls
    module ID
      module Sequence
        def self.example(count=nil, prefix: nil, group_size: nil)
          count ||= 2
          group_size ||= 1

          group_member_cycle = group_size.times.cycle

          count.times.map do |increment|
            group_member = group_member_cycle.next

            ID::GroupMember.example(increment, group_member: group_member, group_size: group_size, prefix: prefix)
          end
        end

        module Group
          def self.example(count: nil, prefix: nil, size: nil)
            count ||= 4
            size ||= 2

            ids = Sequence.example(count, prefix: prefix, group_size: size)

            ids_by_group_member = Array.new(size) { [] }

            ids.each_with_index do |id, increment|
              group_member = increment % size

              ids_by_group_member[group_member] << id
            end

            return *ids_by_group_member
          end
        end
      end
    end
  end
end
