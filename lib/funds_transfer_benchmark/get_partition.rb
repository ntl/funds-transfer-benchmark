module FundsTransferBenchmark
  class GetPartition
    include Settings::Setting

    setting :write_partitions
    setting :read_partitions

    def self.build(settings=nil)
      instance = new
      Settings.set(instance, settings: settings)
      instance
    end

    def advisory_lock(stream_name)
      category = Messaging::StreamName.get_category(stream_name)
      cardinal_id = Messaging::StreamName.get_cardinal_id(stream_name)

      hash_64("#{category}#{hash_64(cardinal_id)}") % write_partitions
    end

    def consumer_group(stream_name)
      category = Messaging::StreamName.get_category(stream_name)
      cardinal_id = Messaging::StreamName.get_cardinal_id(stream_name)

      hash_64("#{category}#{hash_64(cardinal_id)}") % read_partitions
    end

    def hash_64(text)
      [Digest::MD5.hexdigest(text).slice(0, 16).to_i(16)].pack('Q').unpack('q').first
    end

    module Dependency
      def get_partition
        @get_partition ||= GetPartition.build
      end
      attr_writer :get_partition
    end
  end
end
