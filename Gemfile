source "https://rubygems.org"

# Declare your gem"s dependencies in tally.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem "byebug", group: [:development, :test]

gem "rails", "~> 8"
gem "sqlite3", "~> 2.1"

group :development, :test do
  gem "pry-rails"
  gem "rubocop"

  # specific commit until this PR is released to allow RUby 3.1
  # https://github.com/simplecov-ruby/simplecov/pull/1035
  gem "simplecov", require: false, github: "simplecov-ruby/simplecov", ref: "0f1c69af8"
end

group :docs do
  gem "yard"
end
