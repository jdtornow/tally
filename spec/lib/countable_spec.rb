require "rails_helper"

module Tally
  RSpec.describe Countable do

    before { Timecop.freeze(Time.new(2018, 9, 1, 8, 30)) }
    after  { Timecop.return }

    let!(:photo) { create(:photo) }
    let!(:photo2) { create(:photo) }

    describe "#increment_tally" do
      it "increments the stat counter for this record" do
        expect  {
          photo.increment_tally(:views)
        }.to change {
          Tally.redis { |conn| conn.get("tally:photo:#{ photo.id }:views@2018-09-01").to_i }
        }.by(1)
      end

      it "adds the photo to the list of stats for today" do
        is_member = Tally.redis { |conn| conn.sismember("tally@2018-09-01", "photo:#{ photo.id }:views") }
        is_member = is_member == false ? false : is_member.to_i == 1 || is_member == true

        expect(is_member).to eq(false)

        photo.increment_tally(:views)

        is_now_member = Tally.redis { |conn| conn.sismember("tally@2018-09-01", "photo:#{ photo.id }:views") }
        is_now_member = is_now_member == true || is_now_member.to_i == 1

        expect(is_now_member).to eq(true)
      end
    end

    describe "#tally_records" do
      before do
        photo.increment_tally :views, 2
        photo.increment_tally :clicks

        # for other record
        photo2.increment_tally :opens
        photo2.increment_tally :sessions

        Archiver.archive!
      end

      it "returns the records for the given recordable" do
        expect(photo.tally_records).to be_kind_of(ActiveRecord::Relation)
        expect(photo.tally_records.count).to eq(2)
        expect(photo.tally_records.pluck(:key).sort).to eq(%w( clicks views ))
      end

      it "performs a search if parameters are given" do
        query = photo.tally_records(key: "views")

        expect(query).to be_kind_of(ActiveRecord::Relation)
        expect(query.count).to eq(1)
        expect(query.pluck(:key).sort).to eq(%w( views ))
      end
    end

  end
end
