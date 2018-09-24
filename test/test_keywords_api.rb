require "test/unit"
require_relative '../lib/smart_init/main'

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

class KeywordsApiTest < Test::Unit::TestCase
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
