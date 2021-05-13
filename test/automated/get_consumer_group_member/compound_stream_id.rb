require_relative '../automated_init'

context "Get Consumer Group Member" do
  context "Compound Stream ID" do
    cardinal_id = Controls::ID::Random.example
    stream_ids = [cardinal_id, SecureRandom.hex(8)]

    get_consumer_group_member = ConsumerGroup::GetMember.new

    consumer_group_size = 11
    get_consumer_group_member.consumer_group_size = consumer_group_size

    category = Controls::StreamName::Category.random

    control_stream_name = Messaging::StreamName.stream_name(cardinal_id, category)
    control_consumer_group_member = get_consumer_group_member.(control_stream_name)

    stream_name = Messaging::StreamName.stream_name(stream_ids, category)
    consumer_group_member = get_consumer_group_member.(stream_name)

    comment "Stream name: #{stream_name.inspect}"
    comment consumer_group_member.inspect

    detail "Control Consumer Group Member: #{control_consumer_group_member.inspect}"

    test "IDs after the cardinal ID are ignored" do
      assert(consumer_group_member == control_consumer_group_member)
    end
  end
end
