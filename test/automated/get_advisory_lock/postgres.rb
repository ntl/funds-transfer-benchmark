require_relative '../automated_init'

context "Get Advisory Lock" do
  context "Postgres Function" do
    get_advisory_lock = AdvisoryLock::Get.new

    advisory_lock_group_size = ENV['GROUP_SIZE'].to_i
    advisory_lock_group_size = 255 if advisory_lock_group_size.zero?
    get_advisory_lock.advisory_lock_group_size = advisory_lock_group_size

    stream_name = ENV['STREAM_NAME']
    stream_name ||= Controls::StreamName::Random.example
    comment "Stream: #{stream_name.inspect}"

    session = MessageStore::Postgres::Session.build
    advisory_lock_text = session.execute(<<~SQL).first.fetch('advisory_lock')
    SELECT (@hash_64(category('#{stream_name}')) << 8) + MOD(@hash_64(cardinal_id('#{stream_name}')) & 255, #{advisory_lock_group_size}) AS advisory_lock;
    SQL

    advisory_lock = [advisory_lock_text.to_i].pack('q').unpack('Q').first
    comment "Advisory Lock: 0x#{advisory_lock.to_s(16)} (Member: #{advisory_lock & 0xFF})"

    control_advisory_lock = get_advisory_lock.(stream_name)
    detail "Control Advisory Lock: 0x#{control_advisory_lock.to_s(16)} (Member: #{control_advisory_lock & 0xFF})"

    test do
      assert(advisory_lock == control_advisory_lock)
    end
  end
end
