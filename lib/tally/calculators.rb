module Tally
  module Calculators

    def calculators
      @calculators ||= []
    end

    def register_calculator(*class_name)
      @calculators ||= []

      class_name.each do |class_name|
        unless @calculators.include?(class_name.to_s)
          @calculators.push(class_name.to_s)
        end
      end

      nil
    end

    def unregister_calculator(*class_names)
      @calculators ||= []

      class_names = class_names.map(&:to_s)

      @calculators.delete_if { |n| class_names.include?(n) }
    end

  end
end
