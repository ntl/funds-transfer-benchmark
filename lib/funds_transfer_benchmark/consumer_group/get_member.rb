module FundsTransferBenchmark
  module ConsumerGroup
    class GetMember
      include Hash64
      include Settings::Setting

      setting :consumer_group_size

      def self.build(consumer_group_size=nil, settings: nil)
        instance = new

        Settings.set(instance, settings: settings)

        if not consumer_group_size.nil?
          instance.consumer_group_size = consumer_group_size
        end

        instance
      end

      def self.call(stream_name, consumer_group_size=nil, settings: nil)
        instance = build(consumer_group_size, settings: settings)
        instance.(stream_name)
      end

      def call(stream_name)
        cardinal_id = Messaging::StreamName.get_cardinal_id(stream_name)
        cardinal_id_hash64 = hash64_signed(cardinal_id)

        cardinal_id_hash64 % consumer_group_size
      end
    end
  end
end
