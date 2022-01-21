module Tally
  # Locates keys for a given day, key, and/or record
  class KeyFinder

    extend ActiveSupport::Autoload

    autoload :Entry

    attr_reader :key
    attr_reader :record
    attr_reader :type

    def initialize(key: nil, day: nil, record: nil, type: nil)
      @key = key.to_s.gsub(":", ".").downcase.strip if key.present?
      @day = day
      @record = record
      @type = type unless record.present?

      @day = @day.to_date if Time === @day
    end

    def day
      @day ||= Time.current.utc.to_date
    end

    def entries
      @entries ||= all_keys.map do |key|
        if match = key.match(entry_regex)
          Entry.new(match, key, day)
        end
      end.compact
    end

    def keys
      entries.map(&:key).compact.uniq
    end

    def raw_keys
      all_keys
    end

    # load up all records for the given keys, tries to batch them by model type
    # so there's not an N+1 here
    def records
      models = entries.reduce({}) do |result, entry|
        result[entry.type] ||= []
        result[entry.type].push(entry.id)
        result
      end

      models.map do |model, ids|
        next unless ids.compact.any?

        if klass = model.to_s.classify.safe_constantize
          klass.where(id: ids)
        end
      end.compact.flatten
    end

    def types
      entries.map(&:type).compact.uniq
    end

    def self.find(**args)
      new(**args).entries
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
        @day_key ||= if day == "*"
          "*"
        else
          day.strftime(Tally.config.date_format)
        end
      end

      def entry_regex
        @entry_regex ||= Regexp.new("#{ Tally.config.prefix }:?(?<record>[^:]+:[\\d]+)?:?(?<key>[^:]+)?@")
      end

      def scan_from_redis(cursor: "0")
        Tally.redis { |conn| conn.scan(cursor, match: scan_key) }
      end

      def scan_key
        @scan_key ||= if key.present? && record.present?
          "#{ Tally.config.prefix }:#{ record.model_name.i18n_key }:#{ record.id }:#{ key }@#{ day_key }"
        elsif key.present? && type.present?
          "#{ Tally.config.prefix }:#{ type }:*:#{ key }@#{ day_key }"
        elsif record.present?
          "#{ Tally.config.prefix }:#{ record.model_name.i18n_key }:#{ record.id }:*@#{ day_key }"
        elsif type.present?
          "#{ Tally.config.prefix }:#{ type }:*:*@#{ day_key }"
        elsif key.present?
          "#{ Tally.config.prefix }:*#{ key }@#{ day_key }"
        else
          "#{ Tally.config.prefix }*@#{ day_key }"
        end
      end

  end
end
