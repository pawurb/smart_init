# frozen_string_literal: true

require "test/unit"
require_relative '../lib/smart_init/main'

class TestAllPublicAccessors
  extend SmartInit
  initialize_with :attribute_1, :attribute_2, public_accessors: true
  is_callable

  def call
    [attribute_1, attribute_2]
  end
end

class TestSomePublicAccessors
  extend SmartInit
  initialize_with :attribute_1, :attribute_2, public_accessors: [:attribute_1]
  is_callable

  def call
    [attribute_1, attribute_2]
  end
end

class TestDefaultPublicAccessors
  extend SmartInit
  initialize_with :attribute_1, attribute_2: 2, public_accessors: [:attribute_2]

  def call
    [attribute_1, attribute_2]
  end
end

class HashApiPublicTestAccessors < Test::Unit::TestCase
  def test_all_public
    service = TestAllPublicAccessors.new(attribute_1: "a", attribute_2: "b")
    assert_nothing_raised do
      service.attribute_1 = "c"
      service.attribute_2 = "d"
    end
    assert_equal service.attribute_1, "c"
    assert_equal service.attribute_2, "d"
  end

  def test_some_public
    service = TestSomePublicAccessors.new(attribute_1: "a", attribute_2: "b")
    assert_nothing_raised do
      service.attribute_1 = "c"
    end
    assert_equal service.attribute_1, "c"
    assert_raise NoMethodError do
      service.attribute_2
    end
    assert_raise NoMethodError do
      service.attribute_2 = "d"
    end
  end

  def test_default_public
    service = TestDefaultPublicAccessors.new(attribute_1: "a")
    assert_nothing_raised do
      service.attribute_2 = 3
    end
    assert_equal service.attribute_2, 3
    assert_raise NoMethodError do
      service.attribute_1 = "b"
    end
    assert_raise NoMethodError do
      service.attribute_1
    end
  end
end
