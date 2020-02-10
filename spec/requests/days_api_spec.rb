require "rails_helper"

RSpec.describe "Days API", type: :request do

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

    create(:record, day: "2018-09-03", key: "impressions", value: 2, recordable: photo2)
    create(:record, day: "2018-09-08", key: "impressions", value: 10, recordable: photo2)
  end

  describe "GET /tally/days" do
    it "renders the list of recent days" do
      get "/tally/days"

      expect(response.status).to eq(200)
      expect(response.media_type).to eq("application/json")

      expect(response_json).to include("days")
      expect(response_json["days"]).to eq(%w( 2018-09-08 2018-09-05 2018-09-04 2018-09-03 2018-09-02 2018-09-01 ))
    end

    it "has pagination details" do
      get "/tally/days"

      expect(response.status).to eq(200)
      expect(response.media_type).to eq("application/json")

      expect(response_json).to include("meta")
      expect(response_json["meta"]).to include("next_page")
      expect(response_json["meta"]).to include("current_page")
      expect(response_json["meta"]).to include("previous_page")
      expect(response_json["meta"]).to include("per_page")

      expect(response_json["meta"]["current_page"]).to eq(1)
      expect(response_json["meta"]["per_page"]).to eq(24)
      expect(response_json["meta"]["next_page"]).to be_nil
    end
  end

  describe "GET /tally/days/photo/1" do
    it "renders the list of recent keys" do
      get "/tally/days/photo/#{ photo2.id }"

      expect(response.status).to eq(200)
      expect(response.media_type).to eq("application/json")

      expect(response_json).to include("days")
      expect(response_json["days"]).to eq(%w( 2018-09-08 2018-09-03 ))
    end
  end

end
