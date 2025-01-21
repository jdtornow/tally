require "rails_helper"

module Tally
  RSpec.describe SweeperJob do

    describe "#perform" do
      it "calls the sweeper class" do
        expect(Tally::Sweeper).to receive(:sweep!).once

        SweeperJob.perform_now
      end
    end

  end
end
