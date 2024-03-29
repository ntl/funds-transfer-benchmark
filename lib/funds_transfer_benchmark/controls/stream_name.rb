module FundsTransferBenchmark
  module Controls
    module StreamName
      def self.example(id=nil, category: nil)
        id ||= ID.example
        category ||= self.category

        ::Messaging::StreamName.stream_name(id, category)
      end

      def self.category
        Category.example
      end

      module Random
        def self.example(category: nil)
          id = ID::Random.example

          StreamName.example(id, category: category)
        end
      end

      module Category
        def self.example
          'someCategory'
        end

        def self.random
          "#{example}#{SecureRandom.hex(8)}"
        end
      end
    end
  end
end
