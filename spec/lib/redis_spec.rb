require "rails_helper"

RSpec.describe Tally do

  # reset connection
  before do
    Tally.redis_pool = nil
    Tally.redis_connection = REDIS
  end

  after do
    Tally.redis_pool = nil
    Tally.redis_connection = REDIS
  end

  describe ".redis" do
    it "requires a block" do
      expect {
        Tally.redis
      }.to raise_error(ArgumentError)
    end

    it "uses Redis.new by default" do
      Tally.redis_connection = nil
      redis_connection = instance_double("Redis")
      expect(redis_connection).to receive(:get).with("fake").and_return("ok")

      expect(Redis).to receive(:new).with({}).and_return(redis_connection)

      result = Tally.redis { |conn| conn.get("fake") }

      expect(result).to eq("ok")
    end

    it "uses Redis.new with provided config if set" do
      Tally.redis_connection = nil

      config = {
        driver: :ruby,
        url: "redis://127.0.0.1:6379/10",
        ssl_params: {
          verify_mode: OpenSSL::SSL::VERIFY_NONE
        }
      }

      Tally.config.redis_config = config

      redis_connection = instance_double("Redis")
      expect(redis_connection).to receive(:get).with("fake").and_return("ok")

      expect(Redis).to receive(:new).with(config).and_return(redis_connection)

      result = Tally.redis { |conn| conn.get("fake") }

      expect(result).to eq("ok")
    end

    it "allows a custom redis_connection" do
      redis_connection = instance_double("Redis")
      expect(redis_connection).to receive(:get).and_return("ok")

      Tally.redis_connection = redis_connection

      result = Tally.redis { |conn| conn.get("fake") }

      expect(result).to eq("ok")
    end

    it "allows a Sidekiq piggyback pool if Sidekiq is installed" do
      sidekiq = class_double("Sidekiq").as_stubbed_const
      expect(sidekiq).to receive(:redis).and_return("ok")

      result = Tally.redis { |conn| conn.get("fake") }

      expect(result).to eq("ok")
    end
  end

end
