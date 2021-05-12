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

      module Sequence
        def self.example(count=nil, prefix: nil, seed: nil, partitions: nil)
          count ||= 2
          seed_override = seed

          multiple_partitions = !partitions.nil?
          partitions ||= 1

          partition_count = partitions

          partition_cycle = partition_count.times.cycle

          partitions = partition_count.times.map do
            []
          end

          count.times.map do |increment|
            partition = partition_cycle.next

            seed = seed_override || 0

            begin
              id = ID.example(increment, prefix: prefix, seed: seed)

              break if not seed_override.nil?

              hash64 = Hash64.get(id)
              hash64_unsigned = [hash64].pack('q').unpack('Q').first
              advisory_lock_partition = hash64_unsigned % partition_count

              seed += 1
            end until advisory_lock_partition == partition

            partitions[partition] << id
          end

          if multiple_partitions
            return partitions
          else
            return partitions.first
          end
        end
      end
    end
  end
end
