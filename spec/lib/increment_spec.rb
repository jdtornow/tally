require "rails_helper"

module Tally
  RSpec.describe Increment do

    before { Timecop.freeze(Time.new(2018, 9, 1, 8, 30)) }
    after  { Timecop.return }

    let(:key) { :views }
    subject { Increment.new(key) }
    let!(:photo) { create(:photo) }

    describe "#day" do
      it "is today in utc" do
        expect(subject.day).to eq(Date.new(2018, 9, 1))
      end
    end

    describe "#increment" do
      it "increments a key value by 1 for today" do
        expect(REDIS.get("tally:views@2018-09-01").to_i).to eq(0)

        subject.increment

        expect(REDIS.get("tally:views@2018-09-01").to_i).to eq(1)
      end

      it "adds the day to the set of keys" do
        expect(REDIS.smembers("tally@2018-09-01")).to eq([])

        subject.increment

        expect(REDIS.smembers("tally@2018-09-01")).to eq([ "views" ])
      end

      it "increments a key value by X for today" do
        expect(REDIS.get("tally:views@2018-09-01").to_i).to eq(0)

        subject.increment(5)

        expect(REDIS.get("tally:views@2018-09-01").to_i).to eq(5)

        subject.increment

        expect(REDIS.get("tally:views@2018-09-01").to_i).to eq(6)
      end

      it "sets the standard ttl on the new key" do
        subject.increment

        expect(REDIS.smembers("tally@2018-09-01")).to eq([ "views" ])

        sleep 1

        ttl = REDIS.ttl("tally@2018-09-01")

        expect(ttl).to_not be_nil
        expect(ttl).to be > 0
        expect(ttl).to be < 4.days
      end

      it "sets the standard ttl on the day's set" do
        subject.increment

        expect(REDIS.get("tally:views@2018-09-01").to_i).to eq(1)

        sleep 1

        ttl = REDIS.ttl("tally:views@2018-09-01")

        expect(ttl).to_not be_nil
        expect(ttl).to be > 0
        expect(ttl).to be < 4.days
      end

      context "with a record" do
        subject { Increment.new(key, photo) }

        it "increments a key value by 1 for today" do
          expect(REDIS.get("tally:photo:#{ photo.id }:views@2018-09-01").to_i).to eq(0)

          subject.increment

          expect(REDIS.get("tally:photo:#{ photo.id }:views@2018-09-01").to_i).to eq(1)
        end

        it "adds the day to the set of keys" do
          expect(REDIS.smembers("tally@2018-09-01")).to eq([])

          subject.increment

          expect(REDIS.smembers("tally@2018-09-01")).to eq([ "photo:#{ photo.id }:views" ])
        end

        it "increments a key value by X for today" do
          expect(REDIS.get("tally:photo:#{ photo.id }:views@2018-09-01").to_i).to eq(0)

          subject.increment(5)

          expect(REDIS.get("tally:photo:#{ photo.id }:views@2018-09-01").to_i).to eq(5)

          subject.increment

          expect(REDIS.get("tally:photo:#{ photo.id }:views@2018-09-01").to_i).to eq(6)
        end
      end
    end

    describe ".increment" do
      it "calls new and increment together" do
        expect {
          Increment.increment(:clicks)
          Increment.increment(:clicks, nil, 2)
        }.to change {
          REDIS.get("tally:clicks@2018-09-01").to_i
        }.by(3)
      end

      it "calls new and increment together with a record" do
        expect {
          Increment.increment("publisher.visits", photo)
          Increment.increment("publisher.visits", photo, 2)
        }.to change {
          REDIS.get("tally:photo:#{ photo.id }:publisher.visits@2018-09-01").to_i
        }.by(3)
      end
    end

  end
end
