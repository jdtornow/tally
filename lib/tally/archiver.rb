module Tally
  class Archiver

    def initialize(key: nil, day: nil, record: nil, type: nil)
      @key = key
      @day = day
      @record = record
      @type = type
    end

    def archive!
      remove_existing_records

      finder.entries.each do |entry|
        next if entry.type.present? && !entry.record

        record = if entry.record
          Record.find_or_initialize_by(day: entry.date, key: entry.key, recordable: entry.record)
        else
          Record.find_or_initialize_by(day: entry.date, key: entry.key, recordable: nil)
        end

        record.value = entry.value
        record.save
      end

      enqueue_registered_calculators

      true
    end

    def day
      @day ||= Time.current.utc.to_date
    end

    def self.archive!(*args)
      new(*args).archive!
    end

    private

      def enqueue_registered_calculators
        day_str = day.strftime("%Y-%m-%d")
        calculate_method = Tally.config.perform_calculators == :now ? :perform_now : :perform_later

        Tally.calculators.each do |class_name|
          CalculatorRunnerJob.public_send(calculate_method, class_name, day_str)
        end
      end

      def finder
        @finder ||= Daily.new(key: @key, day: @day, record: @record, type: @type)
      end

      def remove_existing_records
        return if @key.present?
        return if @record.present?
        return if @type.present?

        Record.where(day: day).delete_all
      end

  end
end
