require_relative '../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Count" do
      count = 3

      ids = Controls::ID::Sequence.example(count)

      correct_count = ids.uniq.count == count

      test "Generates the given number of UUIDs" do
        assert(correct_count)
      end
    end
  end
end
