module Tally
  class Increment

    include Keyable

    def increment(by = 1)
      Tally.redis do |conn|
        conn.multi do
          conn.incrby(redis_key, by)
          conn.expire(redis_key, Tally.config.ttl) if Tally.config.ttl.present?

          conn.sadd(daily_key, simple_key)
          conn.expire(daily_key, Tally.config.ttl) if Tally.config.ttl.present?
        end
      end
    end

    def self.increment(key, record = nil, by = 1)
      instance = new(key, record)
      instance.increment(by)
      instance = nil
    end

  end
end
