# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "smart_init/version"

Gem::Specification.new do |s|
  s.name = "smart_init"
  s.version = SmartInit::VERSION
  s.authors = ["pawurb"]
  s.email = ["p.urbanek89@gmail.com"]
  s.summary = %q{ Remove Ruby initializer boilerplate code }
  s.description = %q{ A smart DSL for ruby initializers boilerplate }
  s.homepage = "http://github.com/pawurb/smart_init"
  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(%r{^(test)/})
  s.require_paths = ["lib"]
  s.license = "MIT"
  s.add_development_dependency "rake"
  s.add_development_dependency "byebug"
  s.add_development_dependency "dbg-rb"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "rufo"

  if s.respond_to?(:metadata=)
    s.metadata = { "rubygems_mfa_required" => "true" }
  end
end
