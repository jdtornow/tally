class ClicksController < ApplicationController

  def new
    Tally.increment :clicks

    redirect_to root_path
  end

end
