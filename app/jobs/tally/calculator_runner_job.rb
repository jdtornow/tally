module Tally
  class CalculatorRunnerJob < ApplicationJob

    def perform(class_name, date_str)
      date = Date.parse(date_str)

      runner = CalculatorRunner.new(class_name, date)
      runner.save
    end

  end
end
