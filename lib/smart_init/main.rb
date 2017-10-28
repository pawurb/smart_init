module SmartInit
  @@_init_attributes = []

  def is_callable
    define_singleton_method :call do |*parameters|
      new(*parameters).call
    end
  end

  def initialize_with *attributes
    @_init_attributes = attributes
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
end

class SmartInit::Base
  extend SmartInit
end
