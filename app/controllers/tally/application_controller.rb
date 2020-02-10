module Tally
  class ApplicationController < ActionController::Base

    protect_from_forgery with: :exception

    private

      def search
        @search ||= RecordSearcher.new(search_params)
      end

      def search_params
        params.permit(:type, :id, :key, :start_date, :end_date)
      end

  end
end
