require_relative '../automated_init'

context "Hash64" do
  text = "Some text"
  assert(Hash64.get_signed(text) < 0)

  session = MessageStore::Postgres::Session.build
  control_hash64 = session.execute("SELECT @hash_64('#{text}') AS control_hash_64").first.fetch('control_hash_64')

  hash64 = Hash64.get(text)

  comment hash64.inspect
  detail "Control Hash64: #{control_hash64.inspect}"

  test do
    assert(hash64 == control_hash64)
  end
end
