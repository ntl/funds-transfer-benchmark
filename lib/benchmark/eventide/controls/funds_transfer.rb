module Benchmark
  module Eventide
    module Controls
      module FundsTransfer
        def self.id
          ID.example
        end

        module ID
          def self.example(offset=nil)
            id = Controls::ID.example(offset)
            id.slice!(-12, 12)
            id << '111111111111'
            id
          end
        end
      end
    end
  end
end
