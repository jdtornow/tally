require 'rails_helper'

RSpec.describe Tally do

  describe ".configuration" do
    it "contains some defaults" do
      expect(Tally.config.prefix).to eq("tally")
      expect(Tally.config.ttl).to eq(4.days)
    end

    it "returns nil for unknown keys" do
      expect(Tally.config.something_else).to eq(nil)
    end
  end

  describe ".configure" do
    after do
      Tally.config.my_new_setting = nil
    end

    it "allows setting up the app" do
      expect(Tally.config.my_new_setting).to be_nil

      Tally.configure do |config|
        config.my_new_setting = :is_here
      end

      expect(Tally.config.my_new_setting).to eq(:is_here)
    end
  end

end
