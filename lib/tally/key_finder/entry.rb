module Tally
  # @!visibility private
  class KeyFinder::Entry

    attr_reader :raw_key

    def initialize(match, raw_key, date)
      @match    = match
      @raw_key  = raw_key
      @date     = date if Date === date
    end

    def date
      @date ||= build_date_from_raw_key
    end

    def id
      @id ||= if match[:record]
        match[:record].split(":").last.to_i
      end
    end

    def key
      match[:key]
    end

    def record
      return nil unless type.present?
      return nil unless id.present? && id > 0

      if model = type.classify.safe_constantize
        model.find_by(id: id)
      end
    end

    def type
      @type ||= if match[:record]
        match[:record].split(":").first
      end
    end

    def value
      Tally.redis do |conn|
        conn.get(key_for_value_lookup).to_i
      end
    end

    private

      attr_reader :match

      def build_date_from_raw_key
        if raw_key.to_s =~ /@/
          Date.parse(raw_key.to_s.split("@").last)
        end
      end

      def key_for_value_lookup
        if raw_key.starts_with?("#{ Tally.config.prefix }:")
          raw_key
        else
          "#{ Tally.config.prefix }:#{ raw_key }@#{ date&.strftime('%Y-%m-%d') }"
        end
      end

  end
end
