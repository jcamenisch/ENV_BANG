class ENV_BANG
  module Formatter
    class << self
      def formatted_error(var, description)
        indent(4, "

Missing required environment variable: #{var}#{description and "\n" <<
unindent(description) }
        ")
      end

      def unindent(string)
        width = string.scan(/^ */).map(&:length).min
        string.gsub(/^ {#{width}}/, '')
      end

      def indent(width, string)
        string.gsub("\n", "\n#{' ' * width}")
      end
    end
  end
end
