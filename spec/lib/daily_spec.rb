require "rails_helper"

module Tally
  RSpec.describe Daily do

    before { Timecop.freeze(Time.new(2018, 9, 1, 8, 30)) }
    after  { Timecop.return }

    let!(:photo1) { create(:photo) }
    let!(:photo2) { create(:photo) }
    let!(:photo3) { create(:photo) }

    subject { Daily.new }

    before do
      Tally.redis do |conn|
        conn.set("tally:users@2018-09-01", 10)
        conn.set("tally:sessions@2018-09-01", 20)
        conn.set("tally:sessions@2018-08-30", 23)
        conn.set("tally:clicks@2018-09-01", 2)
        conn.set("tally:photo:#{ photo1.id }:clicks.image@2018-09-01", 48)
        conn.set("tally:photo:#{ photo1.id }:clicks.title@2018-09-01", 32)
        conn.set("tally:photo:#{ photo1.id }:clicks.title@2018-08-30", 3)
        conn.set("tally:photo:#{ photo1.id }:clicks@2018-08-30", 2)
        conn.set("tally:photo:#{ photo1.id }:clicks@2018-09-01", 89)
        conn.set("tally:photo:#{ photo2.id }:clicks@2018-09-01", 120)
        conn.set("tally:photo:#{ photo3.id }:clicks@2018-09-01", 78)
        conn.set("tally:photo:#{ photo3.id }:views@2018-09-01", 78)
        conn.set("tally:thing:2:views@2018-09-01", 15)

        conn.sadd("tally@2018-09-01", [
          "users",
          "sessions",
          "clicks",
          "photo:#{ photo1.id }:clicks.image",
          "photo:#{ photo1.id }:clicks.title",
          "photo:#{ photo1.id }:clicks",
          "photo:#{ photo2.id }:clicks",
          "photo:#{ photo3.id }:clicks",
          "photo:#{ photo3.id }:views",
          "thing:2:views"
        ])

        conn.sadd("tally@2018-08-30", [
          "photo:#{ photo1.id }:clicks.title",
          "sessions",
          "photo:#{ photo1.id }:clicks"
        ])
      end
    end

    describe "#day" do
      it "is today in utc" do
        expect(subject.day).to eq(Date.new(2018, 9, 1))
      end
    end

    describe "#entries" do
      it "contains an entity instance for each key" do
        sample = subject.entries.find { |entry| entry.send(:raw_key) == "photo:#{ photo1.id }:clicks" }

        expect(sample).to be_kind_of(Tally::KeyFinder::Entry)
        expect(sample.key).to eq("clicks")
        expect(sample.date).to eq(Date.new(2018, 9, 1))
        expect(sample.record).to eq(photo1)
        expect(sample.type).to eq("photo")
        expect(sample.id).to eq(photo1.id)
        expect(sample.value).to eq(89)
      end
    end

    describe "#keys" do
      let(:result) { subject.keys }

      it "returns the metrics used for this finder" do
        expect(result).to include("views", "clicks", "sessions", "clicks.title", "clicks.image")
      end
    end

    describe "#raw_keys" do
      let(:result) { subject.raw_keys }

      context "when searching just by day" do
        it "returns all keys for that day" do
          expect(result).to include("users", "sessions", "photo:#{ photo1.id }:clicks")
        end
      end

      context "when searching by day and key" do
        subject { Daily.new(key: "clicks") }

        it "returns all keys for that day" do
          expect(result).to include("clicks", "photo:#{ photo1.id }:clicks", "photo:#{ photo3.id }:clicks")
        end

        it "doesn't include any namespaced non-full matches" do
          expect(result).to_not include("photo:#{ photo1.id }:clicks.image", "photo:#{ photo1.id }:clicks.title")
        end
      end

      context "when searching for a namepace of a key" do
        subject { Daily.new(key: "clicks.*") }

        it "returns all keys matching that namespace for this day" do
          expect(result).to include("photo:#{ photo1.id }:clicks.image", "photo:#{ photo1.id }:clicks.title")
        end
      end

      context "when searching by record and day" do
        subject { Daily.new(record: photo1) }

        it "finds all keys for a record and day" do
          expect(result).to include("photo:#{ photo1.id }:clicks.image", "photo:#{ photo1.id }:clicks")
        end

        it "doesn't include other records of the type" do
          expect(result).to_not include("photo:#{ photo2.id }:clicks", "thing:2:views")
        end
      end

      context "when searching by record and key" do
        subject { Daily.new(record: photo1, key: "clicks") }

        it "finds all keys for a record and day" do
          expect(result).to include("photo:#{ photo1.id }:clicks")
        end

        it "doesn't include other records of the type" do
          expect(result).to_not include("photo:#{ photo2.id }:clicks", "thing:2:views", "photo:#{ photo1.id }:clicks.image")
        end
      end

      context "when searching by record and key namespace" do
        subject { Daily.new(record: photo1, key: "clicks*") }

        it "finds all keys for a record and day" do
          expect(result).to include("photo:#{ photo1.id }:clicks", "photo:#{ photo1.id }:clicks.image")
        end

        it "doesn't include other records of the type" do
          expect(result).to_not include("photo:#{ photo2.id }:clicks", "thing:2:views")
        end
      end

      context "when searching by a particular record type" do
        subject { Daily.new(type: :photo) }

        it "finds all keys for that type and day" do
          expect(result).to include("photo:#{ photo1.id }:clicks.title", "photo:#{ photo3.id }:views")
        end

        it "doesn't return other types" do
          expect(result).to_not include("thing:2:views")
        end

        it "doesn't return records without a type" do
          expect(result).to_not include("users")
        end
      end

      context "when searching by a particular record type and key" do
        subject { Daily.new(type: :photo, key: "clicks") }

        it "finds all keys for that type and day" do
          expect(result).to include("photo:#{ photo1.id }:clicks", "photo:#{ photo2.id }:clicks")
        end

        it "doesn't return other types or keys" do
          expect(result).to_not include("thing:2:views", "photo:#{ photo1.id }:clicks.title")
        end

        it "doesn't return records without a type" do
          expect(result).to_not include("users")
        end
      end
    end

    describe "#records" do
      subject { Daily.new(key: "clicks") }

      let(:result) { subject.records }

      it "returns the records used for this finder" do
        expect(result).to include(photo1, photo2, photo3)
      end
    end

    describe "#types" do
      let(:result) { subject.types }

      it "returns the types found for the given day" do
        expect(result).to include("photo", "thing")
      end

      context "with a specific record" do
        subject { KeyFinder.new(record: photo1) }

        it "only returns that type" do
          expect(result).to include("photo")
          expect(result).to_not include("thing")
        end
      end

      context "with specific key" do
        subject { KeyFinder.new(key: "clicks") }

        it "only returns that type" do
          expect(result).to include("photo")
          expect(result).to_not include("thing")
        end
      end
    end

    describe ".find" do
      it "calls to new().entries" do
        mock = double("Tally::Daily")

        expect(KeyFinder).to receive(:new).with(key: "visits").once.and_return(mock)
        expect(mock).to receive(:entries).once.and_return([ "abc123" ])

        expect(KeyFinder.find(key: "visits")).to eq([ "abc123" ])
      end
    end

  end
end
