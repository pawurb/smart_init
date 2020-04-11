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

  def initialize_with_hash(*required_attrs, **attributes_and_options)

    public_readers = attributes_and_options.delete(:public_readers) || []
    public_accessors = attributes_and_options.delete(:public_accessors) || []
    if  public_readers == true || public_accessors == true
      public_readers = required_attrs
      public_accessors = required_attrs if public_accessors == true
    else
      public_readers += public_accessors
    end

    define_method :initialize do |**parameters|
      required_attrs.each do |required_attr|
        unless parameters.has_key?(required_attr)
          raise ArgumentError, "missing required attribute #{required_attr}"
        end
      end
      (required_attrs + attributes_and_options.keys).each do |attribute|
        value = if parameters.has_key?(attribute)
          parameters.fetch(attribute)
        else
          attributes_and_options[attribute]
        end

        instance_variable_set("@#{attribute}", value)
      end
    end

    instance_eval do
      all_readers = (required_attrs + attributes_and_options.keys)
      attr_reader(*all_readers)
      (all_readers - public_readers).each do |reader|
        private reader
      end
      attr_writer(*public_accessors)
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
