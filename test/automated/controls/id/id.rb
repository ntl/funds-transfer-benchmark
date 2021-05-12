require_relative '../../automated_init'

context "Controls" do
  context "ID" do
    id = Controls::ID.example

    correct_id = "00000000-0000-4000-8000-000000000000"

    comment id.inspect
    detail "Correct ID: #{correct_id.inspect}"

    test do
      assert(id == correct_id)
    end
  end
end
