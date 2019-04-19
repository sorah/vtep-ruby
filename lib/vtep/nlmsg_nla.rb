module Vtep
  # primitive values
  class NlmsgNla
    def self.parse(buf, name, type, template)
      _, _, value = buf.unpack("SS#{template}")
      new(name, value, type: type, template: template)
    end

    def initialize(name, value, type: nil, template: nil)
      @name = name
      @value = value
      @type = type
      @template = template
    end

    attr_accessor :type, :name, :value, :template

    def length
      if @template
        [type, value].pack("S#{@template}").size
      else
        [type].pack("S").size
      end
    end

    def to_a
      if @template
        [length, type, value]
      else
        [length, type]
      end
    end

    def template
      "SS#{@template}"
    end
  end
end
