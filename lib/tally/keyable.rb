require "active_support/concern"

module Tally
  module Keyable

    extend ActiveSupport::Concern

    included do
      attr_reader :key
      attr_reader :record
    end

    def initialize(key, record = nil)
      @key = key.to_s.gsub(":", ".").downcase.strip
      @record = record
    end

    def day
      @day ||= Time.current.utc.to_date
    end

    private

      def daily_key
        "#{ prefix }@#{ date_key }"
      end

      def date_key
        @date_key ||= day.strftime(Tally.config.date_format)
      end

      def prefix
        Tally.config.prefix
      end

      def record_key
        if record
          "#{ record.model_name.i18n_key }:#{ record.id }"
        end
      end

      def redis_key
        @redis_key ||= "#{ prefix }:#{ simple_key }@#{ date_key }"
      end

      def simple_key
        @simple_key ||= if record.respond_to?(:model_name)
          "#{ record_key }:#{ key }"
        else
          key
        end
      end

  end
end
