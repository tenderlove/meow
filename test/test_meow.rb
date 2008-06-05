require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

class MeowTest < Test::Unit::TestCase
  def test_initialize
    meep = nil
    assert_nothing_raised {
      meep = Meow.new('Meow Test', ['Notify'])
    }
    assert_not_nil(meep)
  end

  def test_meow_can_register
    meep = Meow.new('Meow Test', ['Notify'])
    assert_nothing_raised {
      meep.register
    }
  end
end
