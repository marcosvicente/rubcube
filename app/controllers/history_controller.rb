class HistoryController < ApplicationController
  def one
    render json: GameDataService.new.get_one
  end
   def two
    render json: GameDataService.new.get_two
  end
end
