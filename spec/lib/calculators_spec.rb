require "rails_helper"

module Tally
  RSpec.describe Calculators do

    describe ".calculators" do
      it "returns the string names of the registered calculators" do
        expect(Tally.calculators).to be_kind_of(Array)
        expect(Tally.calculators).to include("SummaryCalculator")
      end
    end

    describe ".register_calculator" do
      it "registers a class nane" do
        expect(Tally.calculators).to_not include("FakeCalculator")

        Tally.register_calculator :FakeCalculator

        expect(Tally.calculators).to include("FakeCalculator")

        Tally.unregister_calculator(:FakeCalculator)

        expect(Tally.calculators).to_not include("FakeCalculator")
      end
    end

  end
end
