class HistoryController < ApplicationController
  def one
    render json: service.new.get_one
  end
   def two
    render json: service.get_two
  end

  def three
    value =service.get_three(params[:game_number])
    render json: value
  end

  private
  def service
    service = GameDataService.new
  end
end
