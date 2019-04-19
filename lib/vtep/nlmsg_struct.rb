require 'vtep/nlmsg_nla_list'

module Vtep
  class NlmsgStruct
    Member = Struct.new(:name, :type, :cast) do
      def cast_external(val)
        return val unless cast
        cast.extern(val)
      end

      def cast_internal(val)
        return val unless cast
        cast.intern(val)
      end

      def nested?
        type.kind_of?(Class) && type.ancestors.include?(NlmsgStruct)
      end

      def template
        type.kind_of?(String) ? type : type.template
      end
    end

    NlaMember = Struct.new(:name, :nla_type, :type)

    def self.members
      @members ||= []
    end

    def self.grouped_members
      members.slice_when { |a,b| a.nested? || b.nested? }.flat_map do |group|
        if group.all?(&:nested?)
          group
        else
          [group]
        end
      end
    end

    def self.template
      suffix = @add_nla_header ? "SS" : ""
      suffix + members.map(&:template).join
    end

    def self.member(name, type, cast: nil)
      members << Member.new(name, type, cast)
      self.class_eval(<<~EOS,__FILE__,__LINE__+1)
        def #{name.to_s}
          data[:#{name.to_s}]
        end

        def #{name.to_s}=(x)
          data[:#{name.to_s}] = x
        end
      EOS
    end

    def self.nla(nla_types)
      @nlas = nla_types.map.with_index do |(k,v),i|
        if Vtep.const_defined?(k)
          NlaMember.new(k, Vtep.const_get(k), v)
        else
          NlaMember.new(k, i, v)
        end
      end
      @nla_types_map = @nlas.map do |member|
        [member.nla_type, member]
      end.to_h
    end

    def self.nlas
      @nlas
    end

    def self.nla_types_map
      @nla_types_map
    end

    def self.nla_type(num)
      @add_nla_header = true
      @nla_type = num
    end

    def self.add_nla_header?
      @add_nla_header
    end

    def self.nla_type
      @nla_type
    end

    def self.parse(data)
      values = data.unpack(self.nlas ? "#{template}a*" : "#{template}")
      if self.nlas
        remainder = values.pop
        nla_list = NlmsgNlaList.parse(remainder, nla_types_map)
      else
        nla_list = nil
      end
      new(values, nla_list: nla_list)
    end

    def initialize(payload, nla_type: self.class.nla_type, nla_name: nil, nla_list: nil)
      @nla_type = nla_type
      @nla_name = nla_name
      @nla_list = nla_list
      case payload
      when Array
        flat_values = payload.flatten
        if self.class.add_nla_header?
          flat_values.shift(2)
        end

        @data = self.class.grouped_members.flat_map do |group|
          case group
          when Member
            [
              [group.name, group.type.new(flat_values.shift(group.type.members.size))]
            ]
          when Array
            group.zip(flat_values.shift(group.size)).map do |member, value|
              [member.name, member.cast_internal(value)]
            end
          else
            raise TypeError
          end
        end.to_h
      when Hash
        @data = payload
      else 
        raise ArgumentError, "expected an Array or a Hash"
      end
    end

    def template
      "#{self.class.template}#{nla_list&.template}"
    end

    def length
      elems = if self.class.add_nla_header?
        [1,1,*values]
      else
        values
      end
      elems.pack(template).b.size
    end

    def values
      self.class.members.zip(@data.values).flat_map do |member, value|
        if value.kind_of?(NlmsgStruct) || value.kind_of?(NlmsgNla)
          value.to_a
        else
          member.cast_external(value)
        end
      end
    end

    def nla_list
      @nla_list
    end

    def to_a
      if self.class.add_nla_header?
        [length, nla_type, *values, *nla_list&.to_a]
      else
        [*values, *nla_list&.to_a]
      end
    end

    def nla_type
      @nla_type
    end

    def name
      nla_name
    end

    def nla_name
      @nla_name || nla_type
    end

    def pack
      to_a.pack(self.template)
    end

    attr_reader :data
  end
end
