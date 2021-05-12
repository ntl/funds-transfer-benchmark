require_relative '../../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Partition Count" do
      context "Seed Argument Is Also Given" do
        increment = 1
        partition_count = 11
        seed = 0x1111

        id = Controls::ID.example(increment, partition_count, seed: seed)

        correct_id = '00000000-1111-4000-8000-000000000001'

        comment id.inspect
        detail "Correct ID: #{correct_id.inspect}"

        test "Given seed is used and partition count is ignored" do
          assert(id == correct_id)
        end
      end
    end
  end
end
