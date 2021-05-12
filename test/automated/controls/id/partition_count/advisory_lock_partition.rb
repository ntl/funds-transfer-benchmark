require_relative '../../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Partition Count" do
      context "Advisory Lock Partition" do
        partition_count = 3

        category = Controls::StreamName::Category.random

        advisory_lock_partitions = {}

        ids = 5.times.map do |increment|
          id = Controls::ID.example(increment, partition_count)

          stream_name = Controls::StreamName.example(id, category: category)
          advisory_lock = AdvisoryLock::Get.(stream_name, partition_count)
          partition = advisory_lock & 0xFF

          advisory_lock_partitions[id] = partition

          comment "ID: #{increment} (ID: #{id.inspect}, Advisory Lock Partition: #{partition}, Lock: 0x#{advisory_lock.to_s(16)})" 

          id
        end

        ids.each.with_index do |id, increment|
          partition = advisory_lock_partitions[id]

          context "ID: #{increment}" do
            context "IDs With Same Advisory Lock Partition" do
              ids.each.with_index do |compare_id, compare_id_increment|
                next if compare_id_increment == increment

                same_partitions = (compare_id_increment % partition_count) == (increment % partition_count)
                if not same_partitions
                  next
                end

                compare_partition = advisory_lock_partitions[compare_id]

                context "Compare ID: #{compare_id_increment}" do
                  test do
                    assert(compare_partition == partition)
                  end
                end
              end
            end

            context "IDs With Different Advisory Lock Partition" do
              ids.each.with_index do |compare_id, compare_id_increment|
                next if compare_id_increment == increment

                same_partitions = (compare_id_increment % partition_count) == (increment % partition_count)
                if same_partitions
                  next
                end

                compare_partition = advisory_lock_partitions[compare_id]

                context "Compare ID: #{compare_id_increment}" do
                  test do
                    refute(compare_partition == partition)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
