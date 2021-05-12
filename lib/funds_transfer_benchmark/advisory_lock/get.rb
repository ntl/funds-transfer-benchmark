module FundsTransferBenchmark
  module AdvisoryLock
    class Get
      include Hash64
      include Settings::Setting

      setting :advisory_lock_pool_size

      def self.build(advisory_lock_pool_size=nil, settings: nil)
        instance = new

        Settings.set(instance, settings: settings)

        if not advisory_lock_pool_size.nil?
          instance.advisory_lock_pool_size = advisory_lock_pool_size
        end

        instance
      end

      def self.call(stream_name, advisory_lock_pool_size=nil, settings: nil)
        instance = build(advisory_lock_pool_size, settings: settings)
        instance.(stream_name)
      end

      def call(stream_name)
        category = Messaging::StreamName.get_category(stream_name)
        category_hash64 = hash64_unsigned(category)

        cardinal_id = Messaging::StreamName.get_cardinal_id(stream_name)
        cardinal_id_hash64 = hash64_unsigned(cardinal_id)

        partition = cardinal_id_hash64 % advisory_lock_pool_size

        (category_hash64 << 8) | partition
      end

      def unsigned_integer(signed_integer)
        [signed_integer].pack('q').unpack('Q').first
      end
    end
  end
end
