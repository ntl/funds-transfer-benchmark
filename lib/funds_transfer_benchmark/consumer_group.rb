module FundsTransferBenchmark
  module ConsumerGroup
    def self.start_attrs
      assure_configuration

      if size == 1
        return {}
      end

      {
        :identifier => identifier,
        :group_member => member,
        :group_size => size
      }
    end

    def self.assure_configuration
      if size == 1
        return if member.nil?
      end

      unless (1..size).include?(member_ordinal)
        fail "A consumer group size of #{size} has been specified; CONSUMER_GROUP_MEMBER must be a value between 1 and #{size}, not #{member_ordinal}"
      end
    end

    def self.size
      group_size = ENV['CONSUMER_GROUP_SIZE']

      if group_size.nil?
        group_size = Settings.get(:consumer_group_size)
      else
        group_size = group_size.to_i
      end

      group_size
    end

    def self.member
      return nil if member_ordinal.nil?

      member_ordinal - 1
    end

    def self.member_ordinal
      ENV['CONSUMER_GROUP_MEMBER']&.to_i
    end

    def self.identifier
      "#{member}-of-#{size}"
    end
  end
end
