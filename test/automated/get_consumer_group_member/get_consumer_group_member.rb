require_relative '../automated_init'

context "Get Consumer Group Member" do
  get_consumer_group_member = ConsumerGroup::GetMember.new

  consumer_group_size = 11
  get_consumer_group_member.consumer_group_size = consumer_group_size
  comment "Consumer Group Size: #{consumer_group_size.inspect}"

  stream_id = Controls::ID::Random.example
  stream_id_hash64 = Hash64.get_signed(stream_id)
  control_consumer_group_member = stream_id_hash64 % consumer_group_size

  stream_name = Controls::StreamName.example(stream_id)

  consumer_group_member = get_consumer_group_member.(stream_name)

  comment consumer_group_member.inspect
  detail "Stream: #{stream_name.inspect}"
  detail "Control Consumer Group Member: #{control_consumer_group_member.inspect}"
  detail "  Stream ID Hash64: 0x#{stream_id_hash64.to_s(16)}"

  test do
    assert(consumer_group_member == control_consumer_group_member)
  end
end
