require_relative '../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Prefix" do
      prefix = 0xAABB
      ids = Controls::ID::Sequence.example(2, prefix: prefix)

      correct_prefix = ids == [
        'aabb0000-0000-4000-8000-000000000000',
        'aabb0000-0000-4000-8000-000000000001'
      ]

      test "Generates UUIDs with the given prefix" do
        assert(correct_prefix)
      end
    end
  end
end
