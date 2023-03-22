require "env_bang/version"
require "env_bang/classes"
require "env_bang/formatter"
require "forwardable"

class ENV_BANG
  class << self
    extend Forwardable
    include Enumerable

    def config(&block)
      instance_eval(&block)
    end

    def use(var, *args)
      var = var.to_s
      description = args.first.is_a?(String) ? args.shift : nil
      options = args.last.is_a?(Hash) ? args.pop : {}

      unless ENV.has_key?(var)
        ENV[var] = options.fetch(:default) { raise_formatted_error(var, description) }.to_s
      end

      vars[var] = options

      # Make sure reading/coercing the value works. If it's going to raise an error, raise it now.
      self[var]
    end

    def raise_formatted_error(var, description)
      e = KeyError.new(Formatter.formatted_error(var, description))
      e.set_backtrace(caller[3..-1])
      raise e
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

    def add_class(klass, &block)
      Classes.send :define_singleton_method, klass.to_s, &block
    end

    def default_class(*args)
      if args.any?
        Classes.default_class = args.first
      else
        Classes.default_class
      end
    end

    def to_h
      keys.map { |k| [k, self[k]] }.to_h
    end

    alias to_hash to_h

    ####################################
    # Implement Hash-like read methods #
    ####################################

    def_delegators :to_h,
      :each, :assoc, :each_pair, :each_value, :empty?, :fetch,
      :invert, :key, :rassoc, :values_at

    def_delegators :vars, :each_key, :has_key?, :key?, :length, :size

    def slice(*requested_keys)
      (requested_keys & keys).map { |k| [k, self[k]] }.to_h
    end

    if {}.respond_to?(:except)
      def except(*exceptions)
        slice(*(keys - exceptions))
      end
    end

    def value?(value)
      values.include?(value)
    end

    alias has_value? value?
  end
end

def ENV!
  ENV_BANG
end
