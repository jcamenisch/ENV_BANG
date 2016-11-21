class ENV_BANG
  module Classes
    class << self
      attr_writer :default_class

      def default_class
        @default_class ||= :StringUnlessFalsey
      end

      def cast(value, options = {})
        public_send(:"#{options.fetch(:class, default_class)}", value, options)
      end

      def boolean(value, options)
        !(value =~ /^(|0|disabled?|false|no|off)$/i)
      end

      def Array(value, options)
        item_options = options.merge(class: options.fetch(:of, default_class))
        value.split(',').map { |v| cast(v.strip, item_options) }
      end

      def Hash(value, options)
        key_options   = options.merge(class: options.fetch(:keys, Symbol))
        value_options = options.merge(class: options.fetch(:of, default_class))
        {}.tap do |h|
          value.split(',').each do |pair|
            key, value = pair.split(':')
            h[cast(key.strip, key_options)] = cast(value.strip, value_options)
          end
        end
      end

      def Symbol(value, options)
        value.to_sym
      end

      def StringUnlessFalsey(value, options)
        boolean(value, options) && value
      end

      def Integer(value, options)
        Kernel.Integer(value)
      end

      def Float(value, options)
        Kernel.Float(value)
      end

      def String(value, options)
        Kernel.String(value)
      end

      def Rational(value, options)
        Kernel.Rational(value)
      end

      def Complex(value, options)
        Kernel.Complex(value)
      end

      def Pathname(value, options)
        Kernel.Pathname(value)
      end

      def URI(value, options)
        Kernel.URI(value)
      end
    end
  end
end
