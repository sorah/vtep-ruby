require 'vtep/nlmsg_struct'
module Vtep
  module Nlas
    class L2addr < NlmsgStruct
      nla_type nil
      member :a, 'C'
      member :b, 'C'
      member :c, 'C'
      member :d, 'C'
      member :e, 'C'
      member :f, 'C'
    end
  end
end
