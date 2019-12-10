# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_init/version'

Gem::Specification.new do |gem|
  gem.name          = "smart_init"
  gem.version       = SmartInit::VERSION
  gem.authors       = ["pawurb"]
  gem.email         = ["p.urbanek89@gmail.com"]
  gem.summary       = %q{ Remove Ruby initializer boilerplate code }
  gem.description   = %q{ A smart DSL for ruby initializers boilerplate }
  gem.homepage      = "http://github.com/pawurb/smart_init"
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = gem.files.grep(%r{^(test)/})
  gem.require_paths = ["lib"]
  gem.license       = "MIT"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "byebug"
  gem.add_development_dependency "test-unit"
end
