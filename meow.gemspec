Gem::Specification.new do |s|
  s.name = %q{meow}
  s.version = "2.1.0.20081101124146"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson"]
  s.date = %q{2008-11-01}
  s.description = %q{Send Growl notifications via Ruby.}
  s.email = ["aaronp@rubyforge.org"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = [".autotest", "CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "icons/fail.png", "icons/initialize.jpeg", "icons/pass.png", "lib/meow.rb", "lib/meow/autotest.rb", "lib/meow/notifier.rb", "meow.gemspec", "test/assets/aaron.jpeg", "test/helper.rb", "test/test_meow.rb", "vendor/hoe.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://meow.rubyforge.org/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{meow}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Send Growl notifications via Ruby.}
  s.test_files = ["test/test_meow.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
