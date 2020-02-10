# frozen_string_literal: true

require "tally/engine"
require "tally/version"
require "active_support/dependencies/autoload"
require "kaminari/activerecord"

require "redis"
require "sidekiq"

module Tally

  extend ActiveSupport::Autoload
  include ActiveSupport::Configurable

  autoload :Archiver
  autoload :Calculator
  autoload :CalculatorRunner
  autoload :Countable
  autoload :Daily
  autoload :Increment
  autoload :Keyable
  autoload :KeyFinder
  autoload :RecordSearcher
  autoload :Sweeper

  eager_autoload do
    autoload :Calculators
  end

  extend Calculators

  configure do |config|
    config.prefix = "tally"
    config.date_format = "%Y-%m-%d"

    # Amount of time a key lives by default
    config.ttl = 4.days
  end

  # piggback on Sidekiq for managing a connection pool to redis
  def self.redis(&block)
    Sidekiq.redis(&block)
  end

  def self.increment(*args)
    Increment.public_send(:increment, *args)
  end

end
