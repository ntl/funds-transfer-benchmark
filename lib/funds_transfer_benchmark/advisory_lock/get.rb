module FundsTransferBenchmark
  module AdvisoryLock
    class Get
      include Hash64
      include Settings::Setting

      setting :advisory_lock_group_size

      def self.build(advisory_lock_group_size=nil, settings: nil)
        instance = new

        Settings.set(instance, settings: settings)

        if not advisory_lock_group_size.nil?
          instance.advisory_lock_group_size = advisory_lock_group_size
        end

        instance
      end

      def self.call(stream_name, advisory_lock_group_size=nil, settings: nil)
        instance = build(advisory_lock_group_size, settings: settings)
        instance.(stream_name)
      end

      def call(stream_name)
        category = Messaging::StreamName.get_category(stream_name)
        category_hash64 = hash64(category)

        cardinal_id = Messaging::StreamName.get_cardinal_id(stream_name)
        group_member = group_member(cardinal_id)

        ((category_hash64 << 8) & (2 ** 64).pred) | group_member
      end

      def group_member(cardinal_id)
        cardinal_id_hash64 = hash64(cardinal_id)

        (cardinal_id_hash64 & 0xFF) % advisory_lock_group_size
      end
    end
  end
end
