module SmartInit
  def is_callable
    define_singleton_method :call do |*parameters|
      new(*parameters).call
    end
  end

  def initialize_with *attributes
    required_attrs = attributes.select { |attr| attr.is_a?(Symbol) }
    default_value_attrs = attributes.select { |attr| attr.is_a?(Hash) }.first || {}

    define_method :initialize do |*parameters|
      required_attrs.each do |required_attr|
        unless parameters.first.has_key?(required_attr)
          raise ArgumentError, "missing required attribute #{required_attr}"
        end
      end

      (required_attrs + default_value_attrs.keys).each do |attribute|
        value = parameters.first[attribute] || default_value_attrs[attribute]
        instance_variable_set("@#{attribute}", value)
      end
    end

    instance_eval do
      private

      attr_reader(*(required_attrs + default_value_attrs.keys).compact)
    end
  end

  def initialize_with_v1 *attributes
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

      attr_reader(*attributes)
    end
  end
end

class SmartInit::Base
  extend SmartInit
end
