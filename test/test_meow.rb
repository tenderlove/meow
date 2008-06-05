require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

class MeowTest < Test::Unit::TestCase
  def test_initialize
    meep = nil
    assert_nothing_raised {
      meep = Meow.new('Meow Test')
    }
    assert_not_nil(meep)
  end

  def test_meow_has_static_method
    assert_nothing_raised {
      Meow.notify('Meow Test', 'Title', 'Description', :priority => :very_high)
    }
  end

  def test_meow_can_notify_with_type
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Title', 'Description', :type => 'Awesome')
    }
  end

  def test_meow_can_notify_with_priority
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Title', 'Description', :priority => :very_high)
    }
  end

  def test_meow_can_notify_without_register
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Title', 'Description')
    }
  end
end
