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
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.register(['Notify'])
    }
  end

  def test_meow_can_notify
    meep = Meow.new('Meow Test')
    meep.register(['Notify'])
    assert_nothing_raised {
      meep.notify('Notify', 'Title', 'Description')
    }
  end

  def test_meow_can_notify_with_priority
    meep = Meow.new('Meow Test')
    meep.register(['Notify'])
    assert_nothing_raised {
      meep.notify('Notify', 'Title', 'Description', :priority => :very_high)
    }
  end

  def test_meow_can_notify_without_register
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Notify', 'Title', 'Description')
    }
  end
end
