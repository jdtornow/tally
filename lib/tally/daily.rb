module Tally
  # Contains all keys set for the given day
  #
  # Can be used to iterate over a large amount of smembers in the daily set
  class Daily < KeyFinder

    def daily_key
      "#{ Tally.config.prefix }@#{ day_key }"
    end

    private

      def all_keys
        @keys ||= build_keys_from_redis
      end

      def build_keys_from_redis
        result = []
        cursor = ""

        scan = scan_from_redis

        while cursor != "0"
          result << scan.last
          cursor = scan.first

          scan = scan_from_redis(cursor: cursor)
        end

        result.flatten
      end

      def day_key
        @day_key ||= day.strftime(Tally.config.date_format)
      end

      def entry_regex
        @entry_regex ||= Regexp.new("(?<record>[^:]+:[\\d]+)?:?(?<key>[^:]+)")
      end

      def scan_from_redis(cursor: "0")
        Tally.redis do |conn|
          conn.sscan(daily_key, cursor, match: scan_key, count: 25)
        end
      end

      def scan_key
        @scan_key ||= if key.present? && record.present?
          "#{ record.model_name.i18n_key }:#{ record.id }:#{ key }"
        elsif key.present? && type.present?
          "#{ type }:*:#{ key }"
        elsif record.present?
          "#{ record.model_name.i18n_key }:#{ record.id }:*"
        elsif type.present?
          "#{ type }:*:*"
        elsif key.present?
          "*#{ key }"
        else
          "*"
        end
      end

  end
end
