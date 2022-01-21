module Tally
  class Sweeper

    def initialize(key: nil, day: "*", record: nil, type: nil)
      @key = key
      @day = day
      @record = record
      @type = type
    end

    def purge_date
      @purge_date ||= 3.days.ago.beginning_of_day.to_date
    end

    def purgeable_keys
      @purgeable_keys ||= finder.entries.map do |entry|
        if entry.date <= purge_date
          entry.raw_key
        end
      end.compact
    end

    def sweep!
      Tally.redis do |conn|
        purgeable_keys.in_groups_of(25, fill_with = nil).each do |group|
          conn.pipelined do
            group.each do |key|
              conn.del(key)
            end
          end
        end
      end
    end

    def self.sweep!(**args)
      new(**args).sweep!
    end

    private

      def finder
        @key_finder ||= KeyFinder.new(key: @key, day: @day, record: @record, type: @type)
      end

  end
end
