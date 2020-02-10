module Tally
  class RecordsController < Tally::ApplicationController

    def index
      records = search.records.page(params[:page]).per(params[:per_page] || 24).without_count

      render json: {
        records: records.map { |record|
          RecordPresenter.new(record).to_hash
        },
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
