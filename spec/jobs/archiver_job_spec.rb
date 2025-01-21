require "rails_helper"

module Tally
  RSpec.describe ArchiverJob do

    describe "#perform" do
      it "calls the archiver class" do
        expect(Tally::Archiver).to receive(:archive!).once

        ArchiverJob.perform_now
      end

      it "calls the archiver class with yesterday" do
        expect(Tally::Archiver).to receive(:archive!).with(day: 1.day.ago.to_date).once

        ArchiverJob.perform_now("yesterday")
      end

      it "calls the archiver class with a date" do
        expect(Tally::Archiver).to receive(:archive!).with(day: Date.new(2025, 1, 12)).once

        ArchiverJob.perform_now("2025-01-12")
      end
    end

  end
end
