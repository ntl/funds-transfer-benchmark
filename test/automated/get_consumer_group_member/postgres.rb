require_relative '../automated_init'

context "Get Consumer Group Member" do
  context "Postgres Function" do
    get_consumer_group_member = ConsumerGroup::GetMember.new

    consumer_group_size = ENV['GROUP_SIZE'].to_i
    consumer_group_size = 255 if consumer_group_size.zero?
    get_consumer_group_member.consumer_group_size = consumer_group_size
    comment "Consumer Group Size: #{consumer_group_size.inspect}"

    stream_name = ENV['STREAM_NAME']
    stream_name ||= Controls::StreamName::Random.example

    session = MessageStore::Postgres::Session.build
    consumer_group_member_text = session.execute(<<~SQL).first.fetch('consumer_group_member')
    SELECT MOD(@hash_64(cardinal_id('#{stream_name}')), #{consumer_group_size}) AS consumer_group_member
    SQL

    consumer_group_member = [consumer_group_member_text.to_i].pack('q').unpack('Q').first

    control_consumer_group_member = get_consumer_group_member.(stream_name)

    comment consumer_group_member.inspect
    detail "Stream: #{stream_name.inspect}"
    detail "Control Consumer Group Member: #{control_consumer_group_member.inspect}"

    test do
      assert(consumer_group_member == control_consumer_group_member)
    end
  end
end
