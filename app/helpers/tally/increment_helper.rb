module Tally
  module IncrementHelper

    def increment_tally(*args)
      Increment.public_send(:increment, *args)

      nil

    # This method should never block UI
    rescue
      nil
    end

  end
end
