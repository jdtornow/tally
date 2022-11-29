require "rails_helper"

module Tally
  RSpec.describe RecordSearcher do

    before { Timecop.freeze(Time.new(2018, 9, 1, 8, 30)) }
    after  { Timecop.return }

    let!(:photo1) { create(:photo) }
    let!(:photo2) { create(:photo) }
    let!(:photo3) { create(:photo) }

    before do
      create(:record, day: "2018-09-01", key: "visits", value: 4)
      create(:record, day: "2018-09-02", key: "visits", value: 5)
      create(:record, day: "2018-09-03", key: "visits", value: 6)
      create(:record, day: "2018-09-04", key: "visits", value: 7)
      create(:record, day: "2018-09-05", key: "visits", value: 8)

      create(:record, day: "2018-09-01", key: "clicks", value: 1)
      create(:record, day: "2018-09-02", key: "clicks", value: 2)
      create(:record, day: "2018-09-03", key: "clicks", value: 3)

      create(:record, day: "2018-09-03", key: "clicks", value: 1, recordable: photo1)
      create(:record, day: "2018-09-02", key: "clicks", value: 2, recordable: photo1)

      create(:record, day: "2018-09-03", key: "clicks", value: 2, recordable: photo2)
      create(:record, day: "2018-09-08", key: "clicks", value: 10, recordable: photo2)
    end

    describe "#days" do
      it "returns keys in that date range" do
        result = RecordSearcher.new(start_date: "2018-09-01", end_date: "2018-09-03").days.pluck(:day).sort

        expect(result).to eq([ Date.new(2018, 9, 1), Date.new(2018, 9, 2), Date.new(2018, 9, 3) ])
      end
    end

    describe "#keys" do
      it "returns keys in that date range" do
        result = RecordSearcher.new(start_date: "2018-09-01", end_date: "2018-09-03").keys.pluck(:key).sort

        expect(result).to eq(%w( clicks visits ))
      end
    end

    describe "#records" do
      context "for a given key" do
        it "returns the most recent records for that key" do
          result = RecordSearcher.search(key: "visits")

          expect(result.size).to eq(5)
        end
      end

      context "for a given date range" do
        it "returns keys in that date range" do
          result = RecordSearcher.search(key: "visits", start_date: "2018-09-01", end_date: "2018-09-03")

          expect(result.size).to eq(3)
          expect(result.map(&:value)).to eq([ 6, 5, 4 ])
        end

        it "returns records after a given date" do
          result = RecordSearcher.search(start_date: "2018-09-06")

          expect(result.size).to eq(1)
          expect(result.map(&:value)).to eq([ 10 ])
        end

        it "returns records before given date" do
          result = RecordSearcher.search(key: "visits", end_date: "2018-09-02")

          expect(result.size).to eq(2)
          expect(result.map(&:value)).to eq([ 5, 4 ])
        end

        it "ignores invalid dates" do
          result = RecordSearcher.search(key: "visits", end_date: "lksdlksdsld")

          expect(result.size).to eq(5)
        end
      end

      context "for a given related record and key" do
        it "returns the most recent records for that key" do
          result = RecordSearcher.search(key: "clicks", record: photo2)

          expect(result.size).to eq(2)
          expect(result.last.value).to eq(2)
          expect(result.first.value).to eq(10)
        end

        it "returns the most recent records for that record by id/type" do
          result = RecordSearcher.search(key: "clicks", id: photo2.id, type: "photo")

          expect(result.size).to eq(2)
          expect(result.last.value).to eq(2)
        end
      end

      context "for a given type of record" do
        it "returns the most recent records for that key" do
          result = RecordSearcher.search(key: "clicks", type: "Photo")

          expect(result.size).to eq(4)
          expect(result.last.value).to eq(2)
          expect(result.first.value).to eq(10)
        end

        it "returns the most recent records for that record by id/type" do
          result = RecordSearcher.search(key: "clicks", id: photo2.id, type: "photo")

          expect(result.size).to eq(2)
          expect(result.last.value).to eq(2)
        end
      end
    end

    describe "#params" do
      it "keeps a regular hash" do
        params = { key: "clicks", id: photo2.id, "type" => "photo" }

        searcher = RecordSearcher.new(params)
        expect(searcher.params).to include(:key, :id, :type)
        expect(searcher.params[:key]).to eq("clicks")
        expect(searcher.params[:id]).to eq(photo2.id)
        expect(searcher.params[:type]).to eq("photo")
      end

      it "converts ActionController::Parameters to a hash" do
        params = ActionController::Parameters.new({ key: "clicks", id: photo2.id, "type" => "photo" })
        params.permit!

        searcher = RecordSearcher.new(params)
        expect(searcher.params).to include(:key, :id, :type)
        expect(searcher.params[:key]).to eq("clicks")
        expect(searcher.params[:id]).to eq(photo2.id)
        expect(searcher.params[:type]).to eq("photo")
      end

      it "doesn't include params hash if not permitted from the controller" do
        params = ActionController::Parameters.new({ something_ugly: true })

        searcher = RecordSearcher.new(params)
        expect(searcher.params).to_not include(:something_ugly)
        expect(searcher.params).to_not include("something_ugly")
      end
    end

    describe ".search" do
      it "calls to new().search" do
        mock = double("Tally::RecordSearcher")

        expect(RecordSearcher).to receive(:new).with({ key: "visits" }).once.and_return(mock)
        expect(mock).to receive(:records).once

        RecordSearcher.search(key: "visits")
      end
    end

  end
end
