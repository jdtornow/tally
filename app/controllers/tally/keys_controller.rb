module Tally
  class KeysController < Tally::ApplicationController

    def index
      records = search.keys.page(params[:page]).per(params[:per_page] || 24).without_count

      render json: {
        keys: records.map(&:key),
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
