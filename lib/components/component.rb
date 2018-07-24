module Components
  class Component
    class << self
      def attributes
        @attributes ||= {}
      end

      def attribute(name, default: nil)
        attributes[name] = { default: default }

        define_method(name) do |value = nil, attributes = nil, &block|
          attributes, value = value, @view.capture(&block) if block

          if value
            attribute = Attribute.new(value, attributes)

            if get_attribute(name).is_a?(Array)
              get_attribute(name) << attribute
            else
              set_attribute(name, attribute)
            end
          else
            get_attribute(name)
          end
        end
      end
    end

    def initialize(view, attributes = {})
      @view = view

      self.class.attributes.each do |name, options|
        value = attributes.delete(name) || options[:default].dup

        attribute =
          if value.is_a?(Array)
            value.map { |v| Attribute.new(v) }
          elsif value
            Attribute.new(value)
          end

        set_attribute(name, attribute)
      end
    end

    private

    def get_attribute(name)
      instance_variable_get("@#{name}")
    end

    def set_attribute(name, value)
      instance_variable_set("@#{name}", value)
    end
  end
end
