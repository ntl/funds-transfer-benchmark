module Benchmark
  module Eventide
    module Measurements
      class WriteThroughput
        include Initializer
        include Settings::Setting

        include GetPartition::Dependency

        setting :operations

        def session
          @session ||= MessageStore::Postgres::Session.build
        end

        def io
          @io ||= StringIO.new
        end
        attr_writer :io

        attr_accessor :start_time
        attr_accessor :finish_time

        def read_position
          @read_position ||= 0
        end
        attr_writer :read_position

        def messages
          @messages ||= 0
        end
        attr_writer :messages

        def self.build(settings: nil, io: nil)
          io ||= Defaults.io

          instance = new
          Settings.set(instance, settings: settings)
          instance.io = io
          instance
        end

        def self.call(settings: nil)
          instance = build(settings: settings)
          instance.()
        end

        def call
          loop do
            initial_batch = read_position.zero?

            messages = get_next_messages

            if initial_batch
              self.messages += messages.count - 1
            else
              self.messages += messages.count
            end

            break if messages.empty?

            if initial_batch
              self.start_time = messages[0].time
            end

            self.finish_time = messages[-1].time
          end

          elapsed_time = finish_time - start_time
          throughput = Rational(messages, elapsed_time)

          puts(<<~TEXT % [messages, elapsed_time, throughput])

          Messages: %d
          Write Elapsed Time: %0.3f sec
          Write Throughput: %0.3f msgs/sec

          TEXT
        end

        def get_next_messages
          messages = MessageStore::Postgres::Get::Category.('fundsTransfer:command', position: read_position, session: session)

          if not messages.empty?
            last_message = messages.last

            self.read_position = last_message.global_position + 1
          end

          messages
        end

        module Defaults
          def self.io
            $stdout
          end
        end
      end
    end
  end
end
