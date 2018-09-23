module SmartInit
  @@_attributes = []

  def is_callable
    define_singleton_method :call do |*parameters|
      new(*parameters).call
    end
  end

  def initialize_with *attributes
    class_variable_set(:@@_attributes, attributes)
    @@_attributes = attributes
    class_eval <<-METHOD
      def initialize(#{@@_attributes.map { |a| "#{a}:" }.join(', ')})

        if @@_attributes
          @@_attributes.each_with_index do |attribute, index|
            instance_variable_set(
              "@"+ attribute.to_s,
              eval(attribute.to_s)
            )
          end
        end
      end
    METHOD
  end
end

class SmartInit::Base
  extend SmartInit
end
