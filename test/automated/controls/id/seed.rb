require_relative '../../automated_init'

context "Controls" do
  context "ID" do
    context "Seed" do
      context "Given" do
        seed = 0x1111
        id = Controls::ID.example(seed: seed)

        correct_id = '00000000-1111-4000-8000-000000000000'

        comment id.inspect
        detail "Correct ID: #{correct_id.inspect}"

        test "ID contains the given seed value in hexadecimal" do
          assert(id == correct_id)
        end
      end

      context "Not Given" do
        id = Controls::ID.example

        correct_id = '00000000-0000-4000-8000-000000000000'

        comment id.inspect
        detail "Correct ID: #{correct_id.inspect}"

        test "Seed value is zero" do
          assert(id == correct_id)
        end
      end
    end
  end
end
