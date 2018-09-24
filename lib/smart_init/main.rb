module SmartInit
  def is_callable
    define_singleton_method :call do |*parameters|
      new(*parameters).call
    end
  end

  def initialize_with *attributes
    define_method :initialize do |*parameters|
      if attributes.count != parameters.count
        raise ArgumentError, "wrong number of arguments (given #{parameters.count}, expected #{attributes.count})"
      end

      attributes.zip(parameters).each do |pair|
        name = pair[0]
        value = pair[1]
        instance_variable_set("@#{name}", value)
      end
    end

    instance_eval do
      private

      attr_reader *attributes
    end
  end

  def initialize_with_keywords *attributes
    class_variable_set(:@@_attributes, attributes)
    @@_attributes = attributes

    required_attrs = attributes.select { |attr| attr.is_a?(Symbol) }
    default_value_attrs = attributes.select { |attr| attr.is_a?(Hash) }.first || {}

    class_variable_set(:@@_required_attrs, required_attrs)
    class_variable_set(:@@_default_value_attrs, default_value_attrs)
    @@_required_attrs = required_attrs
    @@_default_value_attrs = default_value_attrs

    class_eval <<-METHOD
      def initialize(#{(@@_required_attrs + @@_default_value_attrs.keys) .map { |a| @@_default_value_attrs[a] ? "#{a}: @@_default_value_attrs[#{a}]" : "#{a}:" }.join(', ')})
        @@_required_attrs&.each do |attribute|
          instance_variable_set(
            "@"+ attribute.to_s,
            eval(attribute.to_s)
          )
        end

        @@_default_value_attrs&.keys.each do |attribute|
          instance_variable_set(
            "@"+ attribute.to_s,
            eval(attribute.to_s) || @@_default_value_attrs[attribute]
          )
        end
      end
    METHOD

    instance_eval do
      private

      attr_reader *(required_attrs + default_value_attrs&.keys)
    end
  end
end

class SmartInit::Base
  extend SmartInit
end
