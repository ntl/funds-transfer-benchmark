module FundsTransferBenchmark
  module Controls
    module ID
      def self.example(increment=nil, prefix: nil, seed: nil)
        increment ||= 0
        prefix ||= 0
        seed ||= 0

        [
          prefix.to_s(16).ljust(8, '0'),
          seed.to_s(16).rjust(4, '0'),
          '4000',
          '8000',
          increment.to_s(16).rjust(12, '0')
        ].join('-')
      end

      module Random
        def self.example
          ::Identifier::UUID::Random.get
        end
      end

      module GroupMember
        def self.example(increment=nil, group_size: nil, group_member: nil, prefix: nil)
          increment ||= 0
          group_size ||= 2
          group_member ||= increment % group_size

          seed = 0

          id = nil

          loop do
            id = ID.example(increment, prefix: prefix, seed: seed)

            id_group_member = Hash64.get_unsigned(id) % group_size
            if id_group_member == group_member
              break
            end

            seed += 1
          end

          id
        end
      end
    end
  end
end
