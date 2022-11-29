module Tally
  class Increment

    include Keyable

    def increment(by = 1)
      Tally.redis do |conn|
        conn.multi do |pipeline|
          pipeline.incrby(redis_key, by)
          pipeline.expire(redis_key, Tally.config.ttl.to_i) if Tally.config.ttl.present?

          pipeline.sadd(daily_key, simple_key)
          pipeline.expire(daily_key, Tally.config.ttl.to_i) if Tally.config.ttl.present?
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
