require "rails_helper"

RSpec.describe "Helpers", type: :request do

  before { Timecop.freeze(Time.new(2018, 9, 1, 8, 30)) }
  after  { Timecop.return }

  describe "GET /test/increment" do
    it "increments the views counter" do
      expect {
        get "/test/increment"
      }.to change {
        REDIS.get("tally:views@2018-09-01").to_i
      }.by(1)
    end
  end

end
