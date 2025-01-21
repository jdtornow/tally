# frozen_string_literal: true

module Tally
  class ArchiverJob < ApplicationJob

    def perform(day = "today")
      case day.to_s
      when /^\d{4}-\d{2}-\d{2}$/
        Tally::Archiver.archive! day: Date.parse(day)
      when "yesterday"
        Tally::Archiver.archive! day: 1.day.ago.to_date
      else
        Tally::Archiver.archive!
      end
    end

  end
end
