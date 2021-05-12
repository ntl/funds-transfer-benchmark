module FundsTransferBenchmark
  module Controls
    module ID
      def self.example(increment=nil, partition_count=nil, prefix: nil, seed: nil)
        increment ||= 0
        prefix ||= 0

        if seed.nil?
          seed = 0

          if not partition_count.nil?
            target_advisory_lock_partition = increment % partition_count

            loop do
              id = self.example(increment, prefix: prefix, seed: seed)

              advisory_lock_partition = Hash64.get_unsigned(id) % partition_count

              if advisory_lock_partition == target_advisory_lock_partition
                return id
              end

              seed += 1
            end
          end
        end

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

          return_single_partition = partitions.nil?
          partitions ||= 1

          partition_count = partitions

          partition_cycle = partition_count.times.cycle

          partitions = partition_count.times.map do
            []
          end

          count.times.map do |increment|
            partition = partition_cycle.next

            id = ID.example(increment, partition_count, seed: seed, prefix: prefix)

            partitions[partition] << id
          end

          if return_single_partition
            return partitions.first
          else
            return partitions
          end
        end
      end
    end
  end
end
