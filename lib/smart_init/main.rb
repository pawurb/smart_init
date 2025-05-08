# frozen_string_literal: true

module SmartInit
  def is_callable(opts = {})
    method_name = if name_from_opts = opts[:method_name]
        name_from_opts.to_sym
      else
        :call
      end

    define_singleton_method method_name do |**parameters|
      new(**parameters).public_send(method_name)
    end
  end

  def initialize_with_hash(*required_attrs, **default_values_and_opts)
    public_readers = default_values_and_opts.delete(:public_readers) || []
    public_accessors = default_values_and_opts.delete(:public_accessors) || []
    if public_readers == true || public_accessors == true
      public_readers = required_attrs + default_values_and_opts.keys
      public_accessors = required_attrs + default_values_and_opts.keys if public_accessors == true
    else
      public_readers += public_accessors
    end

    define_method :initialize do |**parameters|
      required_attrs.each do |required_attr|
        unless parameters.has_key?(required_attr)
          raise ArgumentError, "missing required attribute #{required_attr}"
        end
      end

      parameters.keys.each do |param|
        if !(required_attrs + [:public_readers, :public_accessors]).include?(param) && !default_values_and_opts.keys.include?(param)
          raise ArgumentError, "invalid attribute '#{param}'"
        end
      end

      (required_attrs + default_values_and_opts.keys).each do |attribute|
        value = if parameters.has_key?(attribute)
            parameters.fetch(attribute)
          else
            default_values_and_opts[attribute]
          end

        instance_variable_set("@#{attribute}", value)
      end
    end

    instance_eval do
      all_readers = (required_attrs + default_values_and_opts.keys)
      attr_reader(*all_readers)
      (all_readers - public_readers).each do |reader|
        private reader
      end
      attr_writer(*public_accessors)
    end
  end

  alias initialize_with initialize_with_hash
end

class SmartInit::Base
  extend SmartInit
end
