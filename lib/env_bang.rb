require "env_bang/version"
require "env_bang/classes"
require "env_bang/formatter"

class ENV_BANG
  class << self
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

    def method_missing(method, *args, &block)
      ENV.send(method, *args, &block)
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

    ############################
    # Implement Enumerable API #
    ############################
    def to_h
      keys.map { |k| [k, self[k]] }.to_h
    end

    def each(&block)
      to_h.each(&block)
    end

    ####################################
    # Implement Hash-like read methods #
    ####################################

    def assoc(key)
      to_h.assoc(key)
    end

    def each_key(*key, &block)
      to_h.each_key(*key, &block)
    end

    def each_pair(*args, &block)
      to_h.each_pair(*args, &block)
    end

    def each_value(*args, &block)
      to_h.each_value(*args, &block)
    end

    def empty?
      to_h.empty?
    end

    def except(*keys)
      to_h.except(*keys)
    end

    def fetch(key, *args, &block)
      to_h.fetch(key, *args, &block)
    end

    def invert
      to_h.invert
    end

    def key(value)
      to_h.key(value)
    end

    #def key?(key)
    #  vars.key?(key)
    #end

    #alias has_key? key?

    def length
      to_h.length
    end

    def rassoc(value)
      to_h.rassoc(value)
    end

    alias size length

    #def slice(*keys)
    #  to_h.slice(*keys)
    #end

    alias to_hash to_h

    #def value?(value)
    #  vars.value?(value)
    #end

    #alias has_value? value?

    #def values_at(*keys)
    #  to_h.values_at(*keys)
    #end

    ##########################################################
    # Implement Hash-like write methods                      #
    # These must dump to the underlying ENV data structure--
    # if the key is allowed by configuration
    #
    # TODO: Test & implement the following
    #
    # Note write capability will require each class adapter to be a
    # serializer with load & dump methods.
    ##########################################################

    #def replace
    #end

    #def clear
    #end

    #def shift
    #end

    #def select!
    #end

    #def filter!
    #end

    #def keep_if
    #end

    #def delete_if
    #end

    #def reject!
    #end

    #def delete
    #end

    #def rehash
    #end

    #def store
    #end

    #def update
    #end

    #def merge!
    #end
  end
end

def ENV!
  ENV_BANG
end
