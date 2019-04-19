require 'socket'

require 'vtep/constants'
require 'vtep/nlmsghdr'
require 'vtep/nlmsg'
require 'vtep/nlmsgs'

module Vtep
  class Netlink
    def self.pack_sockaddr_nl(pid, groups)
      [16, 0, pid, groups].pack('SSiL')
    end

    def initialize(family, groups)
      @seq = 0
      @socket = Socket.new(AF_NETLINK, :RAW, family)
      @socket.bind(self.class.pack_sockaddr_nl($$, groups))
    end

    def recv
      hdr = Nlmsghdr.parse(@socket.recv(16))
      len = hdr.len - 16
      body = len > 0 ? @socket.recv(len) : nil

      if hdr.multi?
        raise NotImplementedError, "multi not implemented" # TODO:
      end

      p hdr
      p body

      if hdr.ack?
        ack(hdr)
      end

      case hdr.type
      when NLMSG_ERROR
        msg = Nlmsg.new(hdr, Nlmsgerr.parse(body))
        p msg
      when NLMSG_NOOP, NLMSG_DONE
        msg = Nlmsg.new(hdr, body)
      else
        struct = Vtep::Nlmsgs.find(hdr.type, error: false)
        if struct
          msg = Nlmsg.new(hdr, struct.parse(body))
        else
          msg = Nlmsg.new(hdr, body)
        end
      end

      msg
    end

    def ack(hdr)
      p [:ack, hdr]
      response = Nlmsg.new(nil, Nlmsgerr.new(error: 0, msg: hdr)).make_hdr(type: NLMSG_ERROR, flags: 0, seq: next_seq)
      @socket.send(response.pack, 0, self.class.pack_sockaddr_nl(0, 0))
    end

    def try_parse(hdr, data)
    end

    def next_seq
      @seq = @seq + 1
    end
  end
end
