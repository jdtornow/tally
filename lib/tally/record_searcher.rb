module Tally
  class RecordSearcher

    attr_reader :params

    def initialize(params = {})
      @params = params || {}

      if ActionController::Parameters === params
        if params.permitted?
          @params = params.to_h
        else
          @params = {}
        end
      end

      @params = @params.symbolize_keys
    end

    def days
      @keys ||= build_search_scope.select(:day).distinct.reorder(day: :desc)
    end

    def keys
      @keys ||= build_search_scope.select(:key).distinct.reorder(:key)
    end

    def records
      @records ||= build_search_scope
    end

    def self.search(*args)
      new(*args).records
    end

    private

      def build_recordable_from_params
        id = params[:id].to_i
        model = params[:type].to_s.classify.safe_constantize

        if id > 0 && model.respond_to?(:find_by_id)
          model.find_by_id(id)
        end
      end

      def build_search_scope
        scope = Record.all

        if recordable
          scope = scope.where(recordable: recordable)
        elsif params[:type].present?
          scope = scope.where(recordable_type: params[:type])
        end

        if key
          scope = scope.where(key: key)
        end

        if start_date && end_date
          scope = scope.where("day BETWEEN ? AND ?", start_date, end_date)
        elsif start_date
          scope = scope.where("day >= ?", start_date)
        elsif end_date
          scope = scope.where("day <= ?", end_date)
        end

        scope.order(day: :desc)
      end

      def end_date
        if params[:end_date]
          @end_date ||= Date.parse(params[:end_date]) rescue nil
        end
      end

      def key
        if params[:key].present?
          @key ||= params[:key].to_s.gsub(":", ".").downcase.strip
        end
      end

      def recordable
        @recordable ||= if ActiveRecord::Base === params[:record]
          params[:record]
        elsif params[:id] && params[:type]
          build_recordable_from_params
        end
      end

      def start_date
        if params[:start_date]
          @start_date ||= Date.parse(params[:start_date]) rescue nil
        end
      end

  end
end
