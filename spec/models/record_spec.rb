require "rails_helper"

module Tally
  RSpec.describe Record, type: :model do

    describe "::validations" do
      it { should validate_presence_of(:day) }
      it { should validate_presence_of(:key) }
    end

    describe "::relationships" do
      it { should belong_to(:recordable).optional }
    end

    describe ".search" do
      it "calls to the record finder" do
        mock = double("Tally::RecordSearcher")

        expect(RecordSearcher).to receive(:new).with({ key: "visits" }).once.and_return(mock)
        expect(mock).to receive(:records).once

        Record.search(key: "visits")
      end
    end

  end
end
