require "env_bang/version"
require "env_bang/formatter"

class ENV_BANG
  class << self
    def config(&block)
      instance_eval(&block)
    end

    def clear_config
      @vars = {}
    end

    def use(var, *args)
      var = var.to_s
      description = args.first.is_a?(String) && args.shift
      options = args.last.is_a?(Hash) ? args.pop : {}

      unless ENV.has_key?(var)
        ENV[var] = options.fetch(:default) { raise_formatted_error(var, description) }.to_s
      end

      vars[var] = options
    end

    def raise_formatted_error(var, description) 
      raise KeyError.new Formatter.formatted_error(var, description)
    end

    def vars
      @vars ||= {}
    end

    def keys
      vars.keys
    end

    def values
      keys.map { |k| self[k] }
    end

    def [](var)
      var = var.to_s
      raise KeyError.new("ENV_BANG is not configured to use var #{var}") unless vars.has_key?(var)

      Classes.cast ENV[var], vars[var]
    end

    def method_missing(method, *args, &block)
      ENV.send(method, *args, &block)
    end
  end

  module Classes
    class << self
      def cast(value, options = {})
        public_send(:"#{options.fetch(:class, :StringUnlessFalsey)}", value, options)
      end

      def boolean(value, options)
        !(value =~ /^(|0|disabled?|false|no|off)$/i)
      end

      def Array(value, options)
        options.delete(:class)
        options[:class] = options[:of] if options[:of]
        value.split(',').map { |value| cast(value.strip, options) }
      end

      def Symbol(value, options)
        value.to_sym
      end

      def StringUnlessFalsey(value, options)
        boolean(value, options) && value
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
