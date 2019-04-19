require 'vtep/nlmsghdr'

module Vtep
  class Nlmsg
    def initialize(hdr, data)
      @hdr = hdr
      if data.is_a?(String)
        @data = data
      else
        @body = data
      end
    end

    attr_reader :hdr, :data, :body

    def make_hdr(type:, flags: 0, seq:, pid: $$)
      raise "hdr already exists" if hdr
      @hdr = Nlmsghdr.new(
        len: 16 + body.pack.size,
        type: type,
        flags: flags,
        seq: seq,
        pid: pid,
      )
    end

    def pack
      "#{hdr.pack}#{body&.pack}"
    end

    def type
      hdr.type
    end

    def flags
      hdr.flags
    end
  end
end
