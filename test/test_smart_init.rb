require "test/unit"
require 'smart_init'

class TestClass
  extend SmartInit
  initialize_with :param1, :param2
end

class SmartInitTest < Test::Unit::TestCase
  def test_number_of_attributes

    assert_nothing_raised do
      TestClass.new(
        "param1_value",
        "param2_value"
      )
    end

    assert_raise ArgumentError do
      TestClass.new(
        "param1_value"
      )
    end
  end
end


