# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_edition/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as_edition"
  spec.version       = ActsAsEdition::VERSION
  spec.authors       = ["Lee Capps"]
  spec.email         = ["himself@leecapps.com"]
  spec.description   = %q{Editions for ActiveRecord models}
  spec.summary       = %q{acts_as_edition is a ruby gem for creating new editions of trees of ActiveRecord objects.}
  spec.homepage      = "https://github.com/jlcapps/acts_as_edition"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('activerecord', ["~> 4.0.0"])
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3"
end
