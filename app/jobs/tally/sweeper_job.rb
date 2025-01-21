# frozen_string_literal: true

module Tally
  class SweeperJob < ApplicationJob

    def perform
      Tally::Sweeper.sweep!
    end

  end
end
