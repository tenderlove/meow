Gem::Specification.new do |s|
  s.name = %q{meow}
  s.version = "1.1.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson"]
  s.date = %q{2008-06-05}
  s.description = %q{Send Growl notifications via Ruby.}
  s.email = ["aaronp@rubyforge.org"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = ["CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/meow.rb", "meow.gemspec", "test/helper.rb", "test/test_meow.rb", "vendor/hoe.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://meow.rubyforge.org/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{meow}
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Send Growl notifications via Ruby.}
  s.test_files = ["test/test_meow.rb"]
end
