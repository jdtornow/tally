require "rails_helper"

RSpec.describe Tally do

  let!(:photo) { create(:photo) }

  describe ".increment" do
    it "calls to Increment.increment with just a key" do
      expect(Tally::Increment).to receive(:increment).once.with(:visits)

      Tally.increment :visits
    end

    it "calls to Increment.increment with a record and key" do
      expect(Tally::Increment).to receive(:increment).once.with(:clicks, photo)

      Tally.increment :clicks, photo
    end
  end

end
