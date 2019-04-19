require 'vtep/nlmsg_struct'
require 'vtep/nlas/ipaddr'
require 'vtep/nlas/l2addr'
require 'vtep/nlas/cacheinfo'

module Vtep
  module Nlmsgs
    class RtmNewneigh < NlmsgStruct
      member :family, 'C'
      member :ifindex, 'i'
      member :state, 'S'
      member :flags, 'C'
      member :type, 'C'
      member :reminder, 'a*'

      nla(
        NDA_UNSPEC: nil,
        NDA_DST: Vtep::Nlas::Ipaddr,
        NDA_LLADDR: Vtep::Nlas::L2addr,
        NDA_CACHEINFO: Vtep::Nlas::Cacheinfo,
        NDA_PROBES: 'L',
        NDA_VLAN: 'S',
        NDA_PORT: 'n',
        NDA_VNI: 'L',
        NDA_IFINDEX: 'L',
        NDA_MASTER: 'L',
      )
    end
  end
end
