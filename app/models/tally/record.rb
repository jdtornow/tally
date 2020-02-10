# == Schema Information
#
# Table name: tally_records
#
#  id              :integer          not null, primary key
#  day             :date
#  recordable_id   :integer
#  recordable_type :string
#  key             :string
#  value           :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

module Tally
  class Record < ApplicationRecord

    validates :day, presence: true
    validates :key, presence: true

    belongs_to :recordable, polymorphic: true, optional: true

    scope :today, -> { where(day: Time.current.utc.to_date) }

    def self.search(*args)
      RecordSearcher.search(*args)
    end

  end
end
