# -*- encoding: utf-8 -*-

require File.expand_path("../lib/tally/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "tally"
  s.version       = Tally::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = [ "John D. Tornow" ]
  s.email         = [ "john@johntornow.com" ]
  s.summary       = "Stats collection and reporting"
  s.description   = "Stats collection and reporting"
  s.homepage      = "https://github.com/jdtornow/tally"
  s.license       = "MIT"
  s.files         = Dir.glob("{app,bin,config,db,lib}/**/*") + %w( README.md Rakefile )
  s.require_paths = %w( lib )

  s.add_dependency "rails", ">= 5.2.0", "< 7"
  s.add_dependency "redis", ">= 4.1"
  s.add_dependency "kaminari-activerecord", "~> 1.1"
  s.add_dependency "zeitwerk", "~> 2.2"

  s.add_development_dependency "rspec-rails", "~> 3.7"
  s.add_development_dependency "factory_bot_rails", "~> 5.1"
  s.add_development_dependency "shoulda-matchers", "~> 4.2"
  s.add_development_dependency "simplecov", "~> 0.11"
  s.add_development_dependency "rspec_junit_formatter", "~> 0.2"
  s.add_development_dependency "timecop", "~> 0.9"

end
