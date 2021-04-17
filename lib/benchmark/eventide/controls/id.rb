module Benchmark
  module Eventide
    module Controls
      module ID
        def self.example(offset=nil, offset_limit: nil)
          id_increment = id_increment(offset, offset_limit: offset_limit)

          AccountComponent::Controls::ID.example(increment: id_increment)
        end

        def self.id_increment(offset=nil, offset_limit: nil)
          offset ||= 0

          if not offset_limit.nil?
            offset %= offset_limit
          end

          offset.to_s(16)
        end
      end
    end
  end
end
