require_relative '../../automated_init'

context "Controls" do
  context "ID" do
    context "Prefix" do
      context "Given" do
        prefix = 0xAABB
        id = Controls::ID.example(prefix: prefix)

        control_id = "aabb0000-0000-4000-8000-000000000000"

        comment id.inspect
        detail "Control ID: #{control_id.inspect}"

        test "First octet of the ID is the given prefix" do
          assert(id == control_id)
        end
      end

      context "Not Given" do
        id = Controls::ID.example

        control_id = "00000000-0000-4000-8000-000000000000"

        comment id.inspect
        detail "Control ID: #{control_id.inspect}"

        test "Prefix is zero" do
          assert(id == control_id)
        end
      end
    end
  end
end
