module Vtep
  module Nlmsgs
    class NotFound < StandardError; end

    TYPES = Vtep.constants.grep(/^RTM_/).map do |name|
      [Vtep.const_get(name), name.to_s.downcase]
    end.to_h

    def self.find(name, error: true)
      retried = false

      name = TYPES[name] || name
      constant_name = name.to_s.gsub(/\A.|_./) { |s| s[-1].upcase }

      begin
        self.const_get constant_name, false
      rescue NameError
        unless retried
          begin
            require "vtep/nlmsgs/#{name}"
          rescue LoadError
          end

          retried = true
          retry
        end

        if error
          raise NotFound, "Couldn't find #{name.inspect}"
        else
          nil
        end
      end
    end

  end
end
