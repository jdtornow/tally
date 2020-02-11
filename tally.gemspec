# frozen_string_literal: true

require File.expand_path("../lib/tally/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "tally"
  s.version       = Tally::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = [ "John D. Tornow" ]
  s.email         = [ "john@johntornow.com" ]
  s.summary       = "Stats collection and reporting"
  s.description   = "Tally is a simple Rails engine for capturing counts of various activities around an app. These counts are quickly captured in Redis then are archived periodically within the app’s default relational database."
  s.homepage      = "https://github.com/jdtornow/tally"
  s.license       = "MIT"
  s.files         = Dir.glob("{app,bin,config,db,lib}/**/*") + %w( README.md Rakefile )
  s.require_paths = %w( lib )

  s.required_ruby_version     = ">= 2.5.7"
  s.required_rubygems_version = ">= 1.8.11"

  s.add_dependency "rails", ">= 5.2.4.1", "< 7"
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
