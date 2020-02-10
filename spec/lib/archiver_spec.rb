require "rails_helper"

module Tally
  RSpec.describe Archiver do

    before { Timecop.freeze(Time.new(2018, 9, 1, 8, 30)) }
    after  { Timecop.return }

    let!(:photo1) { create(:photo) }
    let!(:photo2) { create(:photo) }
    let!(:photo3) { create(:photo) }

    subject { Archiver.new }

    before do
      REDIS.set("tally:clicks@2018-09-01", 2)
      REDIS.set("tally:photo:#{ photo1.id }:clicks.image@2018-09-01", 48)
      REDIS.set("tally:photo:#{ photo1.id }:clicks.title@2018-08-30", 3)
      REDIS.set("tally:photo:#{ photo1.id }:clicks.title@2018-09-01", 32)
      REDIS.set("tally:photo:#{ photo1.id }:clicks@2018-08-30", 2)
      REDIS.set("tally:photo:#{ photo1.id }:clicks@2018-09-01", 89)
      REDIS.set("tally:photo:#{ photo2.id }:clicks@2018-09-01", 120)
      REDIS.set("tally:photo:#{ photo3.id }:clicks@2018-09-01", 78)
      REDIS.set("tally:photo:#{ photo3.id }:views@2018-09-01", 78)
      REDIS.set("tally:sessions@2018-08-30", 23)
      REDIS.set("tally:sessions@2018-09-01", 20)
      REDIS.set("tally:thing:2:views@2018-09-01", 15)
      REDIS.set("tally:users@2018-09-01", 10)

      REDIS.sadd("tally@2018-09-01", [
        "clicks",
        "photo:#{ photo1.id }:clicks.image",
        "photo:#{ photo1.id }:clicks.title",
        "photo:#{ photo1.id }:clicks",
        "photo:#{ photo2.id }:clicks",
        "photo:#{ photo3.id }:clicks",
        "photo:#{ photo3.id }:views",
        "sessions",
        "thing:2:views",
        "users"
      ])

      REDIS.sadd("tally@2018-08-30", [
        "photo:#{ photo1.id }:clicks.title",
        "photo:#{ photo1.id }:clicks",
        "sessions@2018-08-30"
      ])
    end

    describe "#archive!" do
      it "removes any existing data for the day" do
        existing = Record.create(key: "something-old", day: "2018-09-01", value: 10)

        subject.archive!

        expect(Record.find_by_id(existing.id)).to be_nil
      end

      it "adds entries for the keys on this date" do
        subject.archive!

        records = Record.where(day: "2018-09-01")
        expect(records.count).to eq(9)
      end

      it "adds record entries" do
        subject.archive!

        records = Record.where(day: "2018-09-01", recordable: photo1)
        expect(records.count).to eq(3)

        records = Record.where(day: "2018-08-30", recordable: photo1)
        expect(records.count).to eq(0)
      end

      it "doesn't add records without summary set" do
        REDIS.del("tally@2018-09-01")

        subject.archive!

        records = Record.where(day: "2018-09-01", recordable: photo1)
        expect(records.count).to eq(0)

        records = Record.where(day: "2018-08-30", recordable: photo1)
        expect(records.count).to eq(0)
      end

      context "with only a certain type" do
        subject { Archiver.new(type: :photo) }

        it "adds entries for the keys on this date" do
          subject.archive!

          records = Record.where(day: "2018-09-01")
          expect(records.count).to eq(6)
        end
      end

      context "with only a certain key" do
        subject { Archiver.new(key: "sessions") }

        it "adds entries for the keys on this date" do
          subject.archive!

          records = Record.where(day: "2018-09-01")
          expect(records.count).to eq(1)
        end
      end

      context "with only a certain namespace" do
        subject { Archiver.new(key: "clicks.*") }

        it "adds entries for the keys on this date" do
          subject.archive!

          records = Record.where(day: "2018-09-01")
          expect(records.count).to eq(2)
        end
      end

      it "queues up any calculators registered to be run" do
        subject.archive!

        expect(CalculatorRunnerJob).to have_been_enqueued.with("SummaryCalculator", "2018-09-01").once
      end
    end

    describe "#day" do
      it "is today in utc" do
        expect(subject.day).to eq(Date.new(2018, 9, 1))
      end

      context "with a date passed in" do
        subject { Archiver.new(day: Date.new(2018, 8, 30)) }
        it { expect(subject.day).to eq(Date.new(2018, 8, 30)) }
      end
    end

    describe ".archive!" do
      it "calls to new().archive!" do
        mock = double("Tally::Archiver")

        expect(Archiver).to receive(:new).once.and_return(mock)
        expect(mock).to receive(:archive!).once

        Archiver.archive!
      end
    end

  end
end
