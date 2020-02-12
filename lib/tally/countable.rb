require "active_support/concern"

module Tally
  # An ActiveSupport::Concern mixin for Rails models that want to increment counters
  # for a specific model record.
  module Countable

    extend ActiveSupport::Concern

    def increment_tally(key, by = 1)
      return if new_record?

      Tally.increment(key, self, by)
    end

    def tally_records(search_params = {})
      if search_params.present?
        RecordSearcher.search(search_params.merge(record: self))
      else
        Record.where(recordable: self)
      end
    end

  end
end
