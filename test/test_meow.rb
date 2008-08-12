require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
require "timeout"

class MeowTest < Test::Unit::TestCase
  ASSETS = File.expand_path(File.join(File.dirname(__FILE__), "assets"))

  def my_method_name
    /`(.*?)'/.match(caller.first)[1]
  end

  def test_initialize
    meep = nil
    assert_nothing_raised {
      meep = Meow.new('Meow Test')
    }
    assert_not_nil(meep)
  end

  def test_meow_has_static_method
    assert_nothing_raised {
      Meow.notify('Meow Test', 'Title', my_method_name, :priority => :very_high)
    }
  end

  def test_meow_can_notify_with_type
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Title', my_method_name, :type => 'Awesome')
    }
  end

  def test_meow_can_notify_with_priority
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Title', my_method_name, :priority => :very_high)
    }
  end

  def test_meow_can_notify_without_register
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Title', my_method_name)
    }
  end

  def test_import_image
    icon = Meow.import_image(File.join(ASSETS, 'aaron.jpeg'))
    assert_kind_of(OSX::NSImage, icon)
    meep = Meow.new('Meow Test')
    assert_nothing_raised {
      meep.notify('Icon', my_method_name, :icon => icon)
    }
  end

  def test_stickyness
    block_called = false
    meep = Meow.new('Meow Test')
    meep.notify('Sticky Test', my_method_name + "\n(you should not close this by clicking the 'x')", :sticky => true) do
      block_called = true
    end
    while !block_called do
      sleep 1
    end
  end

  def test_clicks_work
    block_called = false
    meep = Meow.new('Meow Test')
    meep.notify('Click Here', my_method_name + "\n(you should not close this by clicking the 'x')", :sticky => true) do
      block_called = true
    end
    while !block_called do
      sleep 1
    end
  end

  def test_run_should_not_block
    Timeout::timeout(1) do
      meep = Meow.new('Meow Test')
      meep.notify('Non blocking test', my_method_name) do
        #callback block
      end
    end
  end
end
