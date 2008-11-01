# -*- ruby -*-

require 'rubygems'
require './vendor/hoe.rb'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'meow'

HOE = Hoe.new('meow', Meow::VERSION) do |p|
  p.readme  = 'README.rdoc'
  p.history = 'CHANGELOG.rdoc'
  p.developer('Aaron Patterson', 'aaronp@rubyforge.org')
end

namespace :gem do
  task :spec do
    File.open("#{HOE.name}.gemspec", 'w') do |f|
      HOE.spec.version = "#{HOE.version}.#{Time.now.strftime("%Y%m%d%H%M%S")}"
      f.write(HOE.spec.to_ruby)
    end
  end
end

# vim: syntax=Ruby
