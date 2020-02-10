class SummaryCalculator

  include Tally::Calculator

  def call
    record_scope.map do |record|
      {
        key: "#{ record.key }.summary",
        value: record.value * 2
      }
    end
  end

end
