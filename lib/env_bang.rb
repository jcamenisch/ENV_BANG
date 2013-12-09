require "env_bang/version"

class ENV_BANG
  class << self
    def config(&block)
      instance_eval(&block)
    end

    def use(var, *args)
      description = args.first.is_a?(String) && args.shift
      options = args.last.is_a?(Hash) ? args.pop : {}

      unless ENV.has_key?(var)
        ENV[var] = options.fetch(:default) { formatted_error(var, description) }.to_s
      end

      # Store the variable, converted to requested class
      klass = :"#{options.fetch(:class, String)}"
      vars[var] = Classes.cast ENV[var], klass, options
    end

    def formatted_error(var, description)
      message = "Missing required environment variable: #{var}"
      message << "\n#{description}" if description
      indent = '    '
      raise KeyError.new "\n#{indent}#{message.gsub "\n", "\n#{indent}"}\n"
    end

    def vars
      @vars ||= {}
    end

    def [](var)
      raise KeyError.new("ENV_BANG is not configured to use var #{var}") unless vars.has_key?(var)

      vars[var]
    end

    def method_missing(method, *args, &block)
      ENV.send(method, *args, &block)
    end
  end

  module Classes
    class << self
      def cast(value, klass, options = {})
        public_send(:"#{klass}", value, options)
      end

      def boolean(value, options)
        !(value =~ /^(|0|disabled?|false|no|off)$/i)
      end

      def Array(value, options)
        klass = options.fetch(:of, String)
        value.split(',').map { |value| cast(value.strip, klass) }
      end

      # Delegate methods like Integer(), Float(), String(), etc. to the Kernel module
      def method_missing(klass, value, options, &block)
        Kernel.send(klass, value)
      end
    end
  end
end

def ENV!
  ENV_BANG
end
