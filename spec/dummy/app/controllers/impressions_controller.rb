class ImpressionsController < ApplicationController

  def new
    Tally.increment :impressions

    redirect_to root_path
  end

end
