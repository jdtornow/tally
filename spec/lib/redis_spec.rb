require "rails_helper"

RSpec.describe Tally do

  # reset connection
  before { Tally.redis_connection = REDIS }
  after { Tally.redis_connection = REDIS }

  describe ".redis" do
    it "requires a block" do
      expect {
        Tally.redis
      }.to raise_error(ArgumentError)
    end

    it "uses Redis.current by default" do
      Tally.redis_connection = nil

      redis_connection = instance_double("Redis")
      expect(redis_connection).to receive(:get).with("fake").and_return("ok")

      expect(Redis).to receive(:current).and_return(redis_connection)

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
