require_relative '../../automated_init'

context "Controls" do
  context "ID Sequence" do
    ids = Controls::ID::Sequence.example

    all_uuids = ids.all? do |id|
      Identifier::UUID.uuid?(id)
    end

    multiple_uuids = all_uuids && ids.uniq.count > 1

    test "Generates multiple UUIDs" do
      assert(multiple_uuids)
    end
  end
end
