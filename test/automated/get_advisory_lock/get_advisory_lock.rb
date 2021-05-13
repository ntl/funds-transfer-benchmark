require_relative '../automated_init'

context "Get Advisory Lock" do
  get_advisory_lock = AdvisoryLock::Get.new

  advisory_lock_group_size = 11
  get_advisory_lock.advisory_lock_group_size = advisory_lock_group_size
  comment "Group Size: #{advisory_lock_group_size.inspect}"

  stream_id = Controls::ID::Random.example
  stream_id_hash64 = Hash64.get_unsigned(stream_id)
  group_member = stream_id_hash64 % advisory_lock_group_size

  category = Controls::StreamName::Category.example
  category_hash64 = Hash64.get_unsigned(category)

  stream_name = Messaging::StreamName.stream_name(stream_id, category)
  comment "Stream: #{stream_name.inspect}"

  advisory_lock = get_advisory_lock.(stream_name)
  control_advisory_lock_hex = "#{category_hash64.to_s(16).rjust(6, '0')}#{group_member.to_s(16).rjust(2, '0')}"
  control_advisory_lock = control_advisory_lock_hex.to_i(16)

  comment "Advisory Lock: 0x#{advisory_lock.to_s(16)}"
  detail "Control Advisory Lock: 0x#{control_advisory_lock_hex}"
  detail "  Category Hash64: 0x#{category_hash64.to_s(16)}"
  detail "  Group Member: #{group_member}, 0x#{group_member.to_s(16).rjust(2, '0')} (Hash64: 0x#{stream_id_hash64.to_s(16)})"

  test do
    assert(advisory_lock == control_advisory_lock)
  end
end
