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

class TestKeywords
  extend SmartInit
  initialize_with_keywords :attribute_1, :attribute_2
  is_callable

  def call
    [attribute_1, attribute_2]
  end
end

class TestKeywordsDefaults
  extend SmartInit
  initialize_with_keywords :attribute_1, attribute_2: "default_value_2", attribute_3: "default_value_3"
  is_callable

  def call
    [attribute_1, attribute_2, attribute_3]
  end
end

class SmartInitTest < Test::Unit::TestCase
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

  def test_keywords
    assert_equal TestKeywords.call(attribute_1: "a", attribute_2: "b"), ["a", "b"]

    assert_raise ArgumentError do
      TestKeywords.new(
        attribute_1: "a"
      )
    end
  end

  def test_keywords_defaults
    assert_equal TestKeywordsDefaults.call(attribute_1: "a"), ["a", "default_value_2", "default_value_3"]
    assert_equal TestKeywordsDefaults.call(attribute_1: "a", attribute_2: "b"), ["a", "b", "default_value_3"]
  end

  private

  def test_object
    @_test_object ||= TestClass.new("attr_1_value", "attr_2_value")
  end
end


