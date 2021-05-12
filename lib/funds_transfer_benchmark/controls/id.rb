module FundsTransferBenchmark
  module Controls
    module ID
      def self.example(increment=nil, prefix: nil, seed: nil)
        increment ||= 0
        prefix ||= 0
        seed ||= 0

        [
          prefix.to_s(16).ljust(8, '0'),
          seed.to_s(16).rjust(4, '0'),
          '4000',
          '8000',
          increment.to_s(16).rjust(12, '0')
        ].join('-')
      end
    end
  end
end
