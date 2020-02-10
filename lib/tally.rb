# frozen_string_literal: true

require "tally/engine"
require "tally/version"
require "active_support/dependencies/autoload"
require "kaminari/activerecord"

require "redis"

begin
  # attempt to load sidekiq if it is installed
  # if not, just use plain Redis + ActiveJob
  require "sidekiq"
rescue LoadError
  nil
end

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

    # Archivers get queued into the background with ActiveJob by default
    # Set to :now to run inline
    config.perform_calculators = :later
  end

  # If sidekiq is available, piggyback on its pooling
  #
  # Otherwise, just use redis directly
  def self.redis(&block)
    raise ArgumentError, "requires a block" unless block_given?

    if defined?(Sidekiq)
      Sidekiq.redis(&block)
    else
      block.call(redis_connection)
    end
  end

  def self.redis_connection
    @redis_connection ||= Redis.current
  end

  def self.redis_connection=(connection)
    @redis_connection = connection
  end

  def self.increment(*args)
    Increment.public_send(:increment, *args)
  end

end
