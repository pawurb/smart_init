module SmartInit
  def is_callable
    define_singleton_method :call do |*parameters|
      new(*parameters).call
    end
  end

  def initialize_with *attributes
    class_variable_set(:@@_attributes, attributes)
    @@_attributes = attributes

    required_attrs = attributes.select { |attr| attr.is_a?(Symbol) }
    default_value_attrs = attributes.select { |attr| attr.is_a?(Hash) }.first || {}

    class_variable_set(:@@_required_attrs, required_attrs)
    class_variable_set(:@@_default_value_attrs, default_value_attrs)
    @@_required_attrs = required_attrs
    @@_default_value_attrs = default_value_attrs

    class_eval <<-METHOD
      def initialize(#{@@_required_attrs.map { |a| "#{a}:" }.join(', ')})
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
