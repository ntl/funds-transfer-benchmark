require_relative '../automated_init'

context "Get Advisory Lock" do
  context "Compound Stream ID" do
    cardinal_id = Controls::ID::Random.example
    stream_ids = [cardinal_id, SecureRandom.hex(8)]

    get_advisory_lock = AdvisoryLock::Get.new

    advisory_lock_group_size = 11
    get_advisory_lock.advisory_lock_group_size = advisory_lock_group_size

    category = Controls::StreamName::Category.random

    control_stream_name = Messaging::StreamName.stream_name(cardinal_id, category)
    control_advisory_lock = get_advisory_lock.(control_stream_name)

    stream_name = Messaging::StreamName.stream_name(stream_ids, category)
    advisory_lock = get_advisory_lock.(stream_name)

    comment "Stream name: #{stream_name.inspect}"
    comment "Advisory Lock: 0x#{advisory_lock.to_s(16)}"

    detail "Control Advisory Lock: 0x#{control_advisory_lock.to_s(16)}"

    test "IDs after the cardinal ID are ignored" do
      assert(advisory_lock == control_advisory_lock)
    end
  end
end
