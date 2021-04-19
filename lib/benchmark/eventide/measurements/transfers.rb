module Benchmark
  module Eventide
    module Measurements
      class Transfers
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

        attr_accessor :start_position
        attr_accessor :start_time

        def read_position
          @read_position ||= 0
        end
        attr_writer :read_position

        def transfers
          @transfers ||= Hash.new do |hash, stream_name|
            hash[stream_name] = Transfer.new(stream_name)
          end
        end
        attr_writer :transfers

        def transfer_count
          @transfer_count ||= 0
        end
        attr_writer :transfer_count

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
          print_header

          loop do
            events = get_next_events

            break if events.empty?

            events.each do |event|
              stream_name = event.stream_name

              transfer = transfers[stream_name]

              if event.type == initiated_type
                transfer.initiated_time = event.time
                transfer.initiated_global_position = event.global_position

                self.start_time ||= event.time
                self.start_position ||= event.global_position

              elsif event.type == transferred_type
                transfer.transferred_time = event.time
                transfer.transferred_global_position = event.global_position

                print_transfer(transfer)

                transfers.delete(stream_name)
                self.transfer_count += 1
              end
            end
          end

          if not transfers.empty?
            io.puts <<~TEXT

            \e[1;31mError: one or more transfer(s) did not finish:\e[39;22m
            TEXT

            print_header

            transfers.each do |_, transfer|
              print_transfer(transfer)
            end
          end

          io.puts
        end

        def print_transfer(transfer)
          cell(:id, transfer.id)

          if transfer.transferred?
            cell(:transferred_time, "+%0.3fs" % transfer.elapsed_time_seconds(start_time))
          else
            cell(:transferred_time, "--", color: :gray)
          end

          cell(:initiated_time, "+%0.3fs" % transfer.start_time_seconds(start_time))

          cell(:number, transfer.number.to_s)

          if transfer.transferred?
            cell(:cycle_time, "%0.3fs" % transfer.cycle_time_seconds)
            cell(:throughput, "%0.3f xfer/s" % transfer.throughput(start_time, transfer_count))
            cell(:messages_throughput, "%0.3f msgs/s" % transfer.messages_throughput(start_time, start_position))
          else
            cell(:cycle_time, "--", color: :gray)
            cell(:throughput, "--", color: :gray)
            cell(:messages_throughput, "--", color: :gray)
          end

          advisory_lock_partition = get_partition.advisory_lock(transfer.stream_name)
          consumer_group_partition = get_partition.consumer_group(transfer.stream_name)
          cell(:partition, "#{advisory_lock_partition} ⇔ #{consumer_group_partition}")

          if transfer.transferred?
            cell(:success, "Yes", color: :green)
          else
            cell(:success, "No", color: :red)
          end

          io.puts
        end

        def print_header
          io.puts

          each_column do |column|
            attr_name = column.attr_name

            if attr_name == :id
              align = :left
            else
              align = :center
            end

            cell(column.attr_name, column.text, align: align)
          end
          io.puts

          each_column do |column|
            border_width = column.width + 2
            border_repetitions = (border_width / 2) + 1

            border = '- ' * border_repetitions

            border = border.slice(0, border_width)

            cell(column.attr_name, border)
          end
          io.puts
        end

        def cell(attr_name, text, align: nil, color: nil)
          align ||= :right

          column = column(attr_name)

          width = column.width

          case align
          when :center
            text = text.center(width)
          when :left
            text = text.ljust(width)
          when :right
            text = text.rjust(width)
          else
            fail "Unknown text alignment #{align.inspect}"
          end

          text = text.center(width + 2)

          if not color.nil?
            if color == :gray
              sgr_codes = [2, 37]
            elsif color == :red
              sgr_codes = [1, 31]
            elsif color == :green
              sgr_codes = [1, 32]
            else
              fail "Unknown color #{color.inspect}"
            end

            text = "\e[#{sgr_codes.join(';')}m#{text}\e[0m"
          end

          io.print("#{text}|")
        end

        def get_next_events
          events = MessageStore::Postgres::Get::Category.('fundsTransfer', position: read_position, session: session)

          if not events.empty?
            last_event = events.last

            self.read_position = last_event.global_position + 1
          end

          events
        end

        def column(attr_name)
          columns.find do |col|
            col.attr_name == attr_name
          end
        end

        def each_column(&blk)
          columns.each do |column|
            blk.(column)
          end
        end

        def columns
          @columns ||= Defaults.columns.map do |attr_name, column_definition|
            Column.build(attr_name, column_definition)
          end
        end

        def initiated_type
          FundsTransferComponent::Messages::Events::Initiated.message_type
        end

        def transferred_type
          FundsTransferComponent::Messages::Events::Transferred.message_type
        end

        Column = Struct.new(:attr_name, :text, :width) do
          def self.build(attr_name, column_definition)
            if column_definition.is_a?(Hash)
              text = column_definition.keys.first
              width = column_definition.values.first
            else
              text = column_definition
              width = text.length
            end

            self.new(attr_name, text, width)
          end
        end

        Transfer = Struct.new(:stream_name, :initiated_time, :initiated_global_position, :transferred_time, :transferred_global_position) do
          def id
            @id ||= Messaging::StreamName.get_id(stream_name)
          end

          def number
            hex, _ = id.split('-', 2)

            hex.to_i(16)
          end

          def start_time_seconds(reference_time)
            initiated_time - reference_time
          end

          def elapsed_time_seconds(reference_time)
            transferred_time - reference_time
          end

          def transferred?
            !transferred_time.nil?
          end

          def cycle_time_seconds
            elapsed_time_seconds(initiated_time)
          end

          def throughput(reference_time, previous_transfers)
            transfers = previous_transfers + 1

            elapsed_time = elapsed_time_seconds(reference_time)

            Rational(transfers, elapsed_time)
          end

          def messages(reference_position)
            transferred_global_position - reference_position
          end

          def messages_throughput(reference_time, reference_position)
            messages = messages(reference_position)

            elapsed_time = elapsed_time_seconds(reference_time)

            Rational(messages, elapsed_time)
          end
        end

        module Defaults
          def self.io
            $stdout
          end

          def self.columns
            {
              :id => { "Funds Transfer ID" => Identifier::UUID.zero.length },
              :transferred_time => "Transferred",
              :initiated_time => "Initiated",
              :number => "Number",
              :cycle_time => "Cycle Time",
              :throughput => { "Throughput" => 16 },
              :messages_throughput => { "Msgs Throughput" => 16 },
              :partition => "Partition",
              :success => "Success"
            }
          end
        end
      end
    end
  end
end
