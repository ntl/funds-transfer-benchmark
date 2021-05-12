require_relative '../../automated_init'

context "Controls" do
  context "ID" do
    context "Increment" do
      context "Given" do
        increment = 0x11
        id = Controls::ID.example(increment)

        correct_id = '00000000-0000-4000-8000-000000000011'

        comment id.inspect
        detail "Correct ID: #{correct_id.inspect}"

        test "ID contains the given increment value in hexadecimal" do
          assert(id == correct_id)
        end
      end

      context "Not Given" do
        id = Controls::ID.example

        correct_id = '00000000-0000-4000-8000-000000000000'

        comment id.inspect
        detail "Correct ID: #{correct_id.inspect}"

        test "Increment is zero" do
          assert(id == correct_id)
        end
      end
    end
  end
end
