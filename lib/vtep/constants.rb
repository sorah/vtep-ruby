module Vtep
  AF_NETLINK = Socket.const_defined?(:AF_NETLINK) ? Socket::AF_NETLINK : 16 # /usr/include/bits/socket.h
  NETLINK_ROUTE = 0 # /usr/include/linux/netlink.h
  RTMGRP_NEIGH = 4

  NLMSG_NOOP = 0x1
  NLMSG_ERROR = 0x2
  NLMSG_DONE = 0x3

  NLA_F_NESTED = 1 << 15
  NLA_F_NET_BYTEORDER = 1 << 14

  # Netlink message flags values (nlmsghdr.flags)
  #
  NLM_F_REQUEST = 1 # It is request message.
  NLM_F_MULTI = 2 # Multipart message, terminated by NLMSG_DONE
  NLM_F_ACK = 4 # Reply with ack, with zero or error code
  NLM_F_ECHO = 8 # Echo this request
  # Modifiers to GET request
  NLM_F_ROOT = 0x100 # specify tree    root
  NLM_F_MATCH = 0x200 # return all matching
  NLM_F_ATOMIC = 0x400 # atomic GET
  NLM_F_DUMP = (NLM_F_ROOT | NLM_F_MATCH)
  # Modifiers to NEW request
  NLM_F_REPLACE = 0x100 # Override existing
  NLM_F_EXCL = 0x200 # Do not touch, if it exists
  NLM_F_CREATE = 0x400 # Create, if it does not exist
  NLM_F_APPEND = 0x800 # Add to end of list

  RTM_NEWNEIGH = 28
  RTM_DELNEIGH = 29
  RTM_GETNEIGH = 30
end
