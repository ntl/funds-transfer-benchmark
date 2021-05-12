require_relative '../automated_init'

context "Get Advisory Lock" do
  context "Compound Stream ID" do
    cardinal_id = Controls::ID::Random.example
    stream_ids = [cardinal_id, SecureRandom.hex(8)]

    get_advisory_lock = AdvisoryLock::Get.new

    advisory_lock_pool_size = 11
    get_advisory_lock.advisory_lock_pool_size = advisory_lock_pool_size

    category = Controls::StreamName::Category.random

    control_stream_name = Messaging::StreamName.stream_name(cardinal_id, category)
    control_advisory_lock = get_advisory_lock.(control_stream_name)

    stream_name = Messaging::StreamName.stream_name(stream_ids, category)
    advisory_lock = get_advisory_lock.(stream_name)

    comment "Stream name: #{stream_name.inspect}"
    comment advisory_lock.inspect

    detail "Control Advisory Lock: #{control_advisory_lock.inspect}"

    test "IDs after the cardinal ID are ignored" do
      assert(advisory_lock == control_advisory_lock)
    end
  end
end
