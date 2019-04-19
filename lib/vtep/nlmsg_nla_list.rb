require 'vtep/nlmsg_nla'
module Vtep
  class NlmsgNlaList
    def self.parse(buf, nla_types)
      list = []
      reminder = buf
      begin
        len, nla_type, reminder = reminder.unpack('SSa*')
        member = nla_types[nla_type]
        nla = if member.type.kind_of?(Class)
          member.type.parse buf[0,len], nla_type: nla_type, nla_name: member.name
        else
          NlmsgNla.new(buf[0,len], member.name, type: nla_type, template: member.type)
        end
        list << nla
        reminder = reminder[len..-1]
      end until reminder.nil? || reminder.empty?
      new(list, nla_types)
    end

    def initialize(list, nla_types)
      @nlas = list
      @nla_types = nla_types
    end

    attr_reader :nlas

    def to_a
      nlas.flat_map(&:to_a)
    end

    def template
      nlas.map(&:template).join
    end

    def pack
      to_a.pack(template)
    end
  end
end
