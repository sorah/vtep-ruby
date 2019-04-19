require 'vtep/constants'
require 'vtep/nlmsg_struct'

module Vtep
  class Nlmsghdr < NlmsgStruct
    member :len, ?L
    member :type, ?S
    member :flags, ?S
    member :seq, ?L
    member :pid, ?L

    def multi?
      flags & NLM_F_MULTI > 0
    end

    def ack?
      flags & NLM_F_ACK > 0
    end
  end
end

