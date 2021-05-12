require_relative '../automated_init'

context "Get Consumer Group Member" do
  context "Build" do
    consumer_group_size_setting = 11

    get_consumer_group_member = ConsumerGroup::GetMember.build(consumer_group_size_setting)

    consumer_group_size = get_consumer_group_member.consumer_group_size

    comment consumer_group_size.inspect
    detail "Setting: #{consumer_group_size_setting.inspect}"

    test "Consumer group size" do
      assert(consumer_group_size == consumer_group_size_setting)
    end
  end
end
