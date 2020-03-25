require "byebug"
require "test/unit"
require_relative '../lib/smart_init/main'

class TestAllPublic
  extend SmartInit
  initialize_with :attribute_1, :attribute_2, public_readers: true
  is_callable

  def call
    [attribute_1, attribute_2]
  end
end

class TestSomePublic
  extend SmartInit
  initialize_with :attribute_1, :attribute_2, public_readers: [:attribute_1]
  is_callable

  def call
    [attribute_1, attribute_2]
  end
end

class TestDefaultPublic
  extend SmartInit
  initialize_with :attribute_1, attribute_2: 2, public_readers: [:attribute_2]

  def call
    [attribute_1, attribute_2]
  end
end

class HashApiPublicTest < Test::Unit::TestCase
  def test_all_public
    service = TestAllPublic.new(attribute_1: "a", attribute_2: "b")
    assert_equal service.attribute_1, "a"
    assert_equal service.attribute_2, "b"
  end

  def test_some_public
    service = TestSomePublic.new(attribute_1: "a", attribute_2: "b")
    assert_equal service.attribute_1, "a"
    assert_raise NoMethodError do
      service.attribute_2
    end
  end

  def test_default_public
    service = TestDefaultPublic.new(attribute_1: "a")
    assert_equal service.attribute_2, 2

    assert_raise NoMethodError do
      service.attribute_1
    end
  end
end

