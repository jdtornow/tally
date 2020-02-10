require "rails_helper"

module Tally
  RSpec.describe CalculatorRunner do

    subject { CalculatorRunner.new("SummaryCalculator", Date.today) }

    before do
      create(:record, day: Date.today, key: "impressions", value: 10)
      create(:record, day: Date.today, key: "clicks", value: 2)
      create(:record, day: 2.days.ago.to_date, key: "clicks", value: 3)
    end

    describe "#save" do
      it "doesn't do anything with an invalid calculator" do
        runner = CalculatorRunner.new("Something::NotFound", Date.today)
        expect(runner).to_not be_valid

        expect(runner.save).to eq(false)
        expect(Record.count).to eq(3)
      end

      it "adds the new summary records that were calculated" do
        expect {
          subject.save
        }.to change {
          Record.count
        }.by(2)

        expect(Record.find_by_key("impressions.summary").value).to eq(20)
        expect(Record.find_by_key("impressions.summary").day).to eq(Date.today)
        expect(Record.find_by_key("clicks.summary").value).to eq(4)
        expect(Record.find_by_key("clicks.summary").day).to eq(Date.today)
      end

      it "associates values with a recordable if a id/type is given" do
        photo = create(:photo)

        values = [
          {
            id: photo.id,
            type: :photo,
            key: "photos",
            value: 100
          }
        ]

        allow(subject).to receive(:values).and_return(values)

        expect {
          subject.save
        }.to change {
          Record.count
        }.by(1)

        record = Record.last

        expect(record.key).to eq("photos")
        expect(record.recordable).to eq(photo)
        expect(record.value).to eq(100)
        expect(record.day).to eq(Date.today)
      end
    end

    describe "#valid?" do
      it "returns true if there is a valid class and date" do
        expect(subject).to be_valid
      end

      it "returns false if not a valid class" do
        runner = CalculatorRunner.new("Something::NotFound", Date.today)
        expect(runner).to_not be_valid
      end

      it "returns false if not a valid date" do
        runner = CalculatorRunner.new("SummaryCalculator", nil)
        expect(runner).to_not be_valid
      end
    end

    describe "#values" do
      it "returns some stats" do
        expect(subject.values).to be_kind_of(Array)
        expect(subject.values.size).to eq(2)

        result_by_key = subject.values.sort { |a, b| a[:key] <=> b[:key] }

        expect(result_by_key[0]).to eq({ key: "clicks.summary", value: 4 })
        expect(result_by_key[1]).to eq({ key: "impressions.summary", value: 20 })
      end
    end

  end
end
