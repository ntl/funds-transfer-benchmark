module Benchmark
  module Eventide
    module ConsumerGroup
      def self.start_attrs
        assure_configuration

        group_member = member - 1
        group_size = size

        {
          :identifier => identifier,
          :group_member => group_member,
          :group_size => group_size
        }
      end

      def self.assure_configuration
        unless (1..size).include?(member)
          fail "A consumer group size of #{size} has been specified; CONSUMER_GROUP_MEMBER must be a value between 1 and #{size}"
        end
      end

      def self.size
        group_size = ENV['CONSUMER_GROUP_SIZE']

        if group_size.nil?
          group_size = Settings.get(:read_partitions)
        else
          group_size = group_size.to_i
        end

        group_size
      end

      def self.member
        ENV.fetch('CONSUMER_GROUP_MEMBER').to_i
      end

      def self.identifier
        "#{member}-of-#{size}"
      end
    end
  end
end
