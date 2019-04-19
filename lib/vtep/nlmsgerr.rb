require 'vtep/nlmsg_struct'

module Vtep
  class Nlmsgerr < NlmsgStruct
    member :error, 'i'
    member :msg, Nlmsghdr

    def ack?
      error == 0
    end
  end
end
