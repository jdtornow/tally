require "rails_helper"

module Tally
  RSpec.describe Sweeper do

    before { Timecop.freeze(Time.new(2018, 9, 1, 8, 30)) }
    after  { Timecop.return }

    let!(:photo) { create(:photo) }

    subject { Sweeper.new }

    before do
      Tally.redis do |conn|
        conn.set("tally:users@2018-09-01", 10)
        conn.set("tally:sessions@2018-09-01", 20)
        conn.set("tally:sessions@2018-08-30", 23)
        conn.set("tally:clicks@2018-09-01", 2)
        conn.set("tally:photo:#{ photo.id }:clicks.image@2018-09-01", 48)
        conn.set("tally:photo:#{ photo.id }:clicks@2018-08-30", 2)
        conn.set("tally:thing:2:views@2018-09-01", 15)

        conn.set("tally:users@2018-07-01", 10)
        conn.set("tally:sessions@2018-07-01", 20)
        conn.set("tally:photo:#{ photo.id }:clicks.image@2018-07-01", 48)
        conn.set("tally:photo:#{ photo.id }:clicks@2018-08-28", 2)

        conn.sadd("tally@2018-07-01", [
          "users",
          "sessions",
          "photo:#{ photo.id }:clicks.image"
        ])

        conn.sadd("tally@2018-08-28", [
          "photo:#{ photo.id }:clicks"
        ])

        conn.sadd("tally@2018-08-30", [
          "photo:#{ photo.id }:clicks",
          "sessions"
        ])

        conn.sadd("tally@2018-09-01", [
          "thing:2:views",
          "users",
          "sessions",
          "clicks",
          "photo:#{ photo.id }:clicks.image"
        ])
      end
    end

    describe "#purge_date" do
      it "defaults to 3 days ago" do
        expect(subject.purge_date).to eq(Date.new(2018, 8, 29))
      end
    end

    describe "#purgeable_keys" do
      it "returns the keys that are old enough to be purged" do
        expect(subject.purgeable_keys).to include("tally:users@2018-07-01", "tally:sessions@2018-07-01", "tally:photo:#{ photo.id }:clicks.image@2018-07-01", "tally:photo:#{ photo.id }:clicks@2018-08-28")
        expect(subject.purgeable_keys).to_not include("tally:users@2018-09-01", "tally:photo:#{ photo.id }:clicks.image@2018-09-01", "tally:thing:2:views@2018-09-01")
      end
    end

    describe "#sweep!" do
      it "deletes the purgeable keys" do
        subject.sweep!

        expect(Tally.redis { |conn| conn.smembers("tally@2018-07-01") }).to eq([])
        expect(Tally.redis { |conn| conn.get("tally:users@2018-07-01") }).to be_nil
        expect(Tally.redis { |conn| conn.get("tally:sessions@2018-07-01") }).to be_nil
        expect(Tally.redis { |conn| conn.get("tally:photo:#{ photo.id }:clicks.image@2018-07-01") }).to be_nil
        expect(Tally.redis { |conn| conn.get("tally:photo:#{ photo.id }:clicks@2018-08-28") }).to be_nil
      end

      it "doesn't touch the other keys" do
        subject.sweep!

        expect(Tally.redis { |conn| conn.smembers("tally@2018-09-01").size }).to_not eq(0)
        expect(Tally.redis { |conn| conn.get("tally:users@2018-09-01").to_i }).to eq(10)
        expect(Tally.redis { |conn| conn.get("tally:sessions@2018-09-01").to_i }).to eq(20)
        expect(Tally.redis { |conn| conn.get("tally:sessions@2018-08-30").to_i }).to eq(23)
        expect(Tally.redis { |conn| conn.get("tally:clicks@2018-09-01").to_i }).to eq(2)
        expect(Tally.redis { |conn| conn.get("tally:photo:#{ photo.id }:clicks.image@2018-09-01").to_i }).to eq(48)
        expect(Tally.redis { |conn| conn.get("tally:photo:#{ photo.id }:clicks@2018-08-30").to_i }).to eq(2)
        expect(Tally.redis { |conn| conn.get("tally:thing:2:views@2018-09-01").to_i }).to eq(15)
      end
    end

    describe ".sweep!" do
      it "calls new().sweep!" do
        mock = double("Tally::Sweeper")
        expect(mock).to receive(:sweep!).once
        expect(Tally::Sweeper).to receive(:new).and_return(mock).once

        Sweeper.sweep!
      end
    end

  end
end
