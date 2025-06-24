class GameDataService

  def call
    get_data
  end

  def get_info_for_game()
    Struct.new(:game_number, :list_causa, :kill_per_cause, :kill_per_game, :kill_per_world)
  end

  private
  def get_data
    data = File.read(Rails.root + "app/service/game.log")
    data_item = get_data_item(data.split("\n"))

    get_init_finish_game(data_item)
  end

  def not_important_name
    [
      "Item:",
      "ClientConnect:",
      "------------------------------------------------------------",
      "Exit:",
      "ClientBegin:",
      "ClientDisconnect:",
      "ClientUserinfoChanged:",
      "score:",
      "red:0",
      "red:2",
      "red:8",
      "0:00",
      "say:"
    ]
  end

  def get_data_item(data)
    item_value = Array.new
    game_play = Struct.new(:time, :title, :value)

    data.each do |item|
      title = item.split(" ")[1]
      value =  item.split(" ")[2..]
      next if not_important_name.include?(title)
      item_value << game_play.new(
        time: item.split(" ")[0],
        title: title,
        value: get_value(title, value)
      )
    end
    item_value
  end

  def get_value(title, value)
    return unless title.eql?("Kill:")
    value.join(" ")
  end

  def get_init_finish_game(item_value)
    all_games  = []
    game_play_item =  []

    game_init = false
    game_number = 0
    item_value.each do |item|
      if item[:title] == "InitGame:" && !game_init
        game_init = true
      elsif item[:title] != "InitGame:" && item[:title] != "ShutdownGame:" && game_init && item[:title] == "Kill:"
        game_play_item << item
      elsif item[:title] == "ShutdownGame:"
        debugger
        game_init = false

        game = { number: game_number, game_play: game_play_item }
        all_games << game

        game_play_item = []
        game_number += 1
      end
      debugger

      all_games
    end
  end
end

# GameDataService.new.call