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
        ENV[var] = options.fetch(:default) do
          message = "Missing required environment variable: #{var}"
          message << "--#{description}" if description
          indent = '    '
          raise KeyError.new "\n#{indent}#{message.gsub "\n", "\n#{indent}"}\n"
        end
      end

      used_vars << var
    end

    def used_vars
      @used_vars ||= Set.new
    end

    def [](var)
      raise KeyError.new("ENV_BANG is not configured to use var #{var}") unless used_vars.include?(var)

      ENV[var]
    end

    def method_missing(method, *args, &block)
      ENV.send(method, *args, &block)
    end
  end
end

def ENV!
  ENV_BANG
end
