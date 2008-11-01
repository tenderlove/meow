require 'meow'

class Meow
  class Autotest
    @icon_dirs = [File.expand_path(
      File.join(File.dirname(__FILE__), '..', '..', 'icons')
    )]

    @@meow = Meow.new('Meow Autotest')

    class << self
      attr_accessor :icon_dirs

      def icon_for action
        @icon_dirs.reverse.each do |dir|
          file = Dir[File.join(dir,'**')].find { |name| name =~ /#{action}/ }
          return file if file
        end
      end
    end

    ::Autotest.add_hook :initialize do |at|
      @@meow.notify "Autotest", 'started', { :icon => icon_for(:initialize) }
    end

    ::Autotest.add_hook :red do |at|
      @@meow.notify "Autotest", "#{at.files_to_test.size} test are fail.",
        { :icon => icon_for(:fail) }
    end

    ::Autotest.add_hook :green do |at|
      if at.tainted
        @@meow.notify "Autotest", "Tests pass!", { :icon => icon_for(:pass) }
      end
    end

    ::Autotest.add_hook :all_good do |at|
      if at.tainted
        @@meow.notify "Autotest", "All tests pass!",
          { :icon => icon_for(:pass) }
      end
    end
  end
end
