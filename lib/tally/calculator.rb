require "active_support/concern"

module Tally
  module Calculator

    extend ActiveSupport::Concern

    included do
      attr_reader :day
    end

    def initialize(day = Date.today)
      @day = day
    end

    # Override in sub class, this is what gets called when the calculator
    # is run. This method is run in the background so it can take a while
    # if needed to summarize data.
    def call
      raise NotImplementedError
    end

    private

      def record_scope
        Record.where(day: day).includes(:recordable)
      end

  end
end
