require "rails_helper"

module Tally
  RSpec.describe CalculatorRunnerJob do

    describe "#perform" do
      it "calls out to the calculator runner" do
        expect(CalculatorRunner).to receive(:new).with("SummaryCalculator", Date.new(2018, 10, 1)).once.and_call_original

        CalculatorRunnerJob.perform_now("SummaryCalculator", "2018-10-01")
      end

      it "errors if an invalid date is provided" do
        expect(CalculatorRunner).to_not receive(:new)

        expect {
          CalculatorRunnerJob.perform_now("SummaryCalculator", "bad")
        }.to raise_error(ArgumentError)
      end
    end

  end
end
