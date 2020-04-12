require "byebug"
require "test/unit"
require_relative '../lib/smart_init/main'

class TestSomePublicMixed
  extend SmartInit
  initialize_with :attribute_1, :attribute_2, :attribute_3, :attribute_4,
                  public_readers: [:attribute_1],
                  public_accessors: [:attribute_2, :attribute_3]
  is_callable

  def call
    [attribute_1, attribute_2, attribute_3, attribute_4]
  end
end

class TestAllReadersSomeAccessorsPublic
  extend SmartInit
  initialize_with :attribute_1, :attribute_2, public_readers: true, public_accessors: [:attribute_2]

  def call
    [attribute_1, attribute_2]
  end
end

class HashApiPublicTest < Test::Unit::TestCase

  def test_readers_some_public_mixed
    service = TestSomePublicMixed.new(
                attribute_1: "a", attribute_2: "b",
                attribute_3: "c", attribute_4: "d"
              )
    assert_nothing_raised do
      service.attribute_1
      service.attribute_2
      service.attribute_3
    end
    assert_raise NoMethodError do
      service.attribute_4
    end
  end

  def test_writers_some_public_mixed
    service = TestSomePublicMixed.new(
                attribute_1: "a", attribute_2: "b",
                attribute_3: "c", attribute_4: "d"
              )
    assert_nothing_raised do
      service.attribute_2 = "e"
      service.attribute_3 = "f"
    end
    assert_equal service.attribute_2, "e"
    assert_equal service.attribute_3, "f"
    assert_raise NoMethodError do
      service.attribute_4 = "g"
    end
  end

  def test_readers_all_readers_some_accessors_public
    service = TestAllReadersSomeAccessorsPublic.new(
                attribute_1: "a", attribute_2: "b"
              )
    assert_nothing_raised do
      service.attribute_1
      service.attribute_2
    end
  end

  def test_writers_all_readers_some_accessors_public
    service = TestAllReadersSomeAccessorsPublic.new(
                attribute_1: "a", attribute_2: "b"
              )
    assert_raise NoMethodError do
      service.attribute_1 = "c"
    end
    assert_nothing_raised do
      service.attribute_2 = "d"
    end
    assert_equal service.attribute_2, "d"
  end
end
