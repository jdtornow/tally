module Tally
  class DaysController < Tally::ApplicationController

    def index
      records = search.days.page(params[:page]).per(params[:per_page] || 24).without_count

      render json: {
        days: records.map(&:day),
        meta: {
          next_page: records.next_page,
          current_page: records.current_page,
          previous_page: records.prev_page,
          per_page: records.limit_value
        }
      }
    end

  end
end
