module FundsTransferBenchmark
  class Settings < ::Settings
    def self.data_source
      'settings/benchmark.json'
    end

    def self.set(receiver, settings: nil)
      settings ||= instance

      default_settings = Defaults.instance
      default_settings.set(receiver)

      settings.set(receiver)
    end

    def self.instance
      @instance ||= build
    end

    def self.get(setting)
      instance.get(setting)
    end

    class Defaults < ::Settings
      def self.instance
        @instance ||= build(data)
      end

      def self.data
        {
          :operations => 1000,
          :throughput_limit => 100,
          :force => false,
          :worst_case => false,
          :advisory_lock_group_size => 1,
          :consumer_group_size => 1,
          :recreate_message_db => true
        }
      end
    end
  end
end
