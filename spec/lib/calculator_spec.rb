require "rails_helper"

module Tally
  RSpec.describe Calculator do

    subject { FakeCalculator }

    describe "#day" do
      it "defaults to today" do
        expect(subject.new.day).to eq(Date.today)
      end

      it "can be changed in initialize" do
        expect(subject.new(Date.new(2018, 9, 1)).day).to eq(Date.new(2018, 9, 1))
      end
    end

    describe "#call" do
      it "raises NotImplementedError by default" do
        expect {
          subject.new.call
        }.to raise_error(NotImplementedError)
      end

      context "with SummaryCalculator" do
        subject { SummaryCalculator.new }

        let(:result) { subject.call }

        before do
          create(:record, day: Date.today, key: "impressions", value: 10)
          create(:record, day: Date.today, key: "clicks", value: 2)
          create(:record, day: 2.days.ago.to_date, key: "clicks", value: 3)
        end

        it "returns some stats" do
          expect(result).to be_kind_of(Array)
          expect(result.size).to eq(2)

          result_by_key = result.sort { |a, b| a[:key] <=> b[:key] }

          expect(result_by_key[0]).to eq({ key: "clicks.summary", value: 4 })
          expect(result_by_key[1]).to eq({ key: "impressions.summary", value: 20 })
        end
      end
    end

  end
end
