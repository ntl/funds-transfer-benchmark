require_relative '../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Count" do
      count = 3

      ids = Controls::ID::Sequence.example(count)

      correct_ids = [
        '00000000-0000-4000-8000-000000000000',
        '00000000-0000-4000-8000-000000000001',
        '00000000-0000-4000-8000-000000000002'
      ]

      test "Generates the given number of UUIDs" do
        assert(ids == correct_ids)
      end
    end
  end
end
