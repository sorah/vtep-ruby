require 'vtep/nlmsg_struct'
module Vtep
  module Nlas
    class Cacheinfo < NlmsgStruct
      nla_type NDA_CACHEINFO
      member :confirmed, 'L'
      member :used, 'L'
      member :updated, 'L'
      member :refcnt, 'L'
    end
  end
end
