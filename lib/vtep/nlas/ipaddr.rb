require 'vtep/nlmsg_struct'
module Vtep
  module Nlas
    module Ipaddr
      def self.parse(buf)
        klass = buf.size > (2+2+4) ? IPv6 : IPv4
        klass.new(buf)
      end

      def self.new(*args)
      end

      class IPv4 < NlmsgStruct
        nla_type nil
        member :a, 'C'
        member :b, 'C'
        member :c, 'C'
        member :d, 'C'
      end

      class IPv6 < NlmsgStruct
        nla_type nil
        member :a, 'N'
        member :b, 'N'
        member :c, 'N'
        member :d, 'N'
      end

    end
  end
end
