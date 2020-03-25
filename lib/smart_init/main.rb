module SmartInit
  def is_callable(opts={})
    method_name = if name_from_opts = opts[:method_name]
      name_from_opts.to_sym
    else
      :call
    end

    define_singleton_method method_name do |*parameters|
      new(*parameters).public_send(method_name)
    end
  end

  def initialize_with_hash *attributes
    public_readers_filter = -> (el) {
      el.is_a?(Hash) && el.keys == [:public_readers]
    }
    attributes = attributes.map do |el|
      if el.is_a?(Hash)
        el.map { |k, v| { k => v } }
      else
       el
      end
    end.flatten

    public_readers = attributes.select(&public_readers_filter)
    attributes.delete_if(&public_readers_filter)
    required_attrs = attributes.select { |el| el.is_a?(Symbol) }

    default_value_attrs = attributes.select { |el| el.is_a?(Hash) }.reduce(Hash.new, :merge) || {}

    define_method :initialize do |*parameters|
      parameters = [{}] if parameters == []
      unless parameters.first.is_a?(Hash)
        raise ArgumentError, "invalid input, expected hash of attributes"
      end

      required_attrs.each do |required_attr|
        unless parameters.first.has_key?(required_attr)
          raise ArgumentError, "missing required attribute #{required_attr}"
        end
      end

      (required_attrs + default_value_attrs.keys).each do |attribute|
        value = if parameters.first.has_key?(attribute)
          parameters.first.fetch(attribute)
        else
          default_value_attrs[attribute]
        end

        instance_variable_set("@#{attribute}", value)
      end
    end

    instance_eval do
      all_readers = (required_attrs + default_value_attrs.keys).compact
      attr_reader(*all_readers)

      if public_readers.count == 0
        all_readers.each do |method_name|
          private method_name
        end
      elsif public_readers.first.fetch(:public_readers).is_a?(Array)
        (all_readers - public_readers.first.fetch(:public_readers)).each do |method_name|
          private method_name
        end
      end
    end
  end

  alias initialize_with initialize_with_hash

  def initialize_with_args *attributes
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
      attr_reader(*attributes)

      attributes.each do |method_name|
        private method_name
      end
    end
  end
end

class SmartInit::Base
  extend SmartInit
end
