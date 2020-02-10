module Tally
  class CalculatorRunner

    attr_reader :date

    def initialize(class_name, date)
      @date       = date
      @class_name = class_name
    end

    def klass
      @klass ||= @class_name.to_s.safe_constantize
    end

    # loop through each value and save in db
    def save
      return false unless valid?

      values.each do |attributes|
        create_record(attributes)
      end

      true
    end

    def values
      return [] unless valid?

      @values ||= [ klass.new(date).call ].flatten
    end

    def valid?
      klass.present? && date.present?
    end

    private

      def create_record(attributes)
        finder = { day: date, key: attributes[:key] }

        id = attributes.delete(:id)
        type = attributes.delete(:type)

        if id && type
          finder[:recordable_id] = id
          finder[:recordable_type] = type.to_s.classify
        end

        record = Record.find_or_initialize_by(finder)

        record.attributes = attributes
        record.save
      end

  end
end
