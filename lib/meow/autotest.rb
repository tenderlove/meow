require 'meow'

class Meow
  class Autotest
    @@meow = Meow.new('Meow Autotest')

    ::Autotest.add_hook :initialize do |at|
      @@meow.notify "Autotest", 'started'
    end

    ::Autotest.add_hook :red do |at|
      @@meow.notify "Autotest", "#{at.files_to_test.size} test are fail."
    end

    ::Autotest.add_hook :green do |at|
      @@meow.notify "Autotest", "Tests pass!" if at.tainted
    end

    ::Autotest.add_hook :all_good do |at|
      @@meow.notify "Autotest", "All tests pass!" if at.tainted
    end
  end
end
