class HistoryController < ApplicationController
  def one
    render json: GameDataService.new.get_one
  end
end
