module FundsTransferBenchmark
  module Hash64
    extend self

    def self.get(text)
      hash64(text)
    end

    def self.get_signed(text)
      hash64_signed(text)
    end

    def self.get_unsigned(text)
      hash64_unsigned(text)
    end

    def hash64(text)
      hash64_signed = hash64_signed(text)
      hash64_signed.abs
    end

    def hash64_signed(text)
      hash64_unsigned = hash64_unsigned(text)

      [hash64_unsigned].pack('Q').unpack('q').first
    end

    def hash64_unsigned(text)
      text_md5 = Digest::MD5.hexdigest(text)

      truncated_md5 = text_md5.slice(0, 16)

      truncated_md5.to_i(16)
    end
  end
end
