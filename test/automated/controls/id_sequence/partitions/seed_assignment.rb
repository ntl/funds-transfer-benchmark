require_relative '../../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Partitions" do
      context "Seed Assignment" do
        partition_count = 2

        ids_1, ids_2 = Controls::ID::Sequence.example(11, partitions: partition_count)

        advisory_locks_1 = ids_1.map do |id|
          stream_name = Controls::StreamName.example(id)
          AdvisoryLock::Get.(stream_name, partition_count)
        end

        advisory_locks_2 = ids_2.map do |id|
          stream_name = Controls::StreamName.example(id)
          AdvisoryLock::Get.(stream_name, partition_count)
        end

        context "First Partition" do
          detail "Advisory Locks: #{advisory_locks_1.map { |lock| "0x#{lock.to_s(16)}" }.inspect}"

          all_advisory_locks_identical = advisory_locks_1.uniq.count == 1

          test "Advisory lock is identical for all IDs" do
            assert(all_advisory_locks_identical)
          end
        end

        context "Second Partition" do
          detail "Advisory Locks: #{advisory_locks_2.map { |lock| "0x#{lock.to_s(16)}" }.inspect}"

          all_advisory_locks_identical = advisory_locks_2.uniq.count == 1

          test "Advisory lock is identical for all IDs" do
            assert(all_advisory_locks_identical)
          end
        end

        test "Advisory locks for each partition differ" do
          refute(advisory_locks_1 == advisory_locks_2)
        end
      end
    end
  end
end
