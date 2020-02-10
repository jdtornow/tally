module Tally
  class RecordPresenter

    def initialize(record)
      @record = record
    end

    def to_hash
      {
        date: @record.day,
        key: @record.key,
        value: @record.value,
        scope: scope
      }
    end

    private

      def scope
        if @record.recordable_id && @record.recordable_type
          {
            type: @record.recordable_type.downcase,
            id: @record.recordable_id
          }
        end
      end

  end
end
