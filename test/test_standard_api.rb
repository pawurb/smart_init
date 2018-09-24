require "test/unit"
require "byebug"
require_relative '../lib/smart_init/main'

class TestClass
  extend SmartInit
  initialize_with :attribute_1, :attribute_2
  is_callable

  def call
    [attribute_1, attribute_2]
  end
end

class TestNoInit
  extend SmartInit
  is_callable

  def call
    'result'
  end
end

def test_object
  @_test_object ||= TestClass.new("attr_1_value", "attr_2_value")
end

class StandardApiTest < Test::Unit::TestCase
  def test_number_of_attributes
    assert_nothing_raised do
      TestClass.new(
        "attr_1_value",
        "attr_2_value"
      )
    end

    assert_raise ArgumentError do
      TestClass.new(
        "attr_1_value"
      )
    end
  end

  def test_instance_variables
    assert_equal test_object.instance_variable_get("@attribute_1"), "attr_1_value"
  end

  def test_private_getters
    assert_raise NoMethodError do
      test_object.attribute_1
    end

    assert_equal test_object.send(:attribute_1), "attr_1_value"
  end

  def test_is_callable
    assert_equal TestClass.call("a", "b"), ["a", "b"]
  end

  def test_is_callable_no_initializers
    assert_equal TestNoInit.call, 'result'
  end
end
