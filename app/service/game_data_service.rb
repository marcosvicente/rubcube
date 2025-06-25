class GameDataService

  def get_one
    data = get_data
    data_item = get_init_finish_game(data)

    info = []
    info_kill = Struct.new(:game_number, :list_motivated, :kill_per_cause, :kill_per_game, :kill_per_world)

    data_item.each do |item|
      if item[:game_play].empty?
        info << info_kill.new(
          game_number: item[:number],
          list_motivated: 0,
          kill_per_cause: 0,
          kill_per_game: 0,
          kill_per_world: 0
        )
      else
         info << info_kill.new(
          game_number: item[:number],
          list_motivated: get_list_motivated(item[:game_play]),
          kill_per_cause: get_kill_per_cause(item[:game_play]),
          kill_per_game: item[:game_play].count,
          kill_per_world: get_kill_per_world(item[:game_play])
        )
      end
    end
     info
  end
  
  def get_two
    data = get_data
    data_item = get_init_finish_game(data)

    info_value = []
    info_kill = Struct.new(:game_number, :scored)

    data_item.each do |item|
      if item[:game_play].empty?

        info_value << info_kill.new(
          game_number: item[:number],
          scored: nil
        )
      else
         info_value << info_kill.new(
          game_number: item[:number],
          scored: player_scored(item[:game_play])
        )
      end
    end
    info_value
  end
 def get_three(game_number)
    data_item = get_one
    return data_item if game_number.nil? || game_number == "all"
    data_item.map{|data| data if data[:game_number] == game_number.to_i }.compact
  end

  private

  def player_scored(game_play)
    all_player_per_game = []
    player = Struct.new(:name, :scored)
    aux = game_play.map(&:value).map{ |a| a.split(": ")[1] }
    aux.each do |item|
      player_name =  item.split("killed")[0].strip

      player_death = item.split("killed")[1].split(" by ")[0].strip
      if all_player_per_game.empty?
        all_player_per_game << player.new(name: player_name, scored: 0)
        all_player_per_game << player.new(name: player_death, scored: 0)
      else
        unless all_player_per_game.map(&:name).include?(player_name)
          all_player_per_game << player.new(name: player_name, scored: 0)
        end
        
        unless all_player_per_game.map(&:name).include?(player_death)
          all_player_per_game << player.new(name: player_death, scored: 0)
        end

        all_player_per_game.each do |item|
          if player_name == player_death
            next
          elsif item.name == player_name
            item.scored += 1
          elsif item.name == player_death
            item.scored -= 1
          end
        end
      end
    end
    all_player_per_game = all_player_per_game.map{|a| a if a[:name] != "<world>" }.compact
    all_player_per_game.sort_by {|a| a[:scored]}.reverse!
  end
  
  def get_list_motivated(game_play)
    game_play_values = game_play.map(&:value).map{|v| v.split(" ")[-1]}.uniq
  end

  def get_kill_per_cause(game_play)
    game_play.map(&:value).map{|v| v.split(" ")[-1]}.tally
  end


  def get_kill_per_world(game_play)
     game_play.map(&:value).map{ |v| v.split(" ").include?("<world>" )}.count(true)
  end

  def get_data
    data = File.read(Rails.root + "app/service/game.log")
    data_item = get_data_item(data.split("\n"))
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

  def list_death
   [ 
    "MOD_UNKNOWN",
    "MOD_SHOTGUN",
    "MOD_GAUNTLET",
    "MOD_MACHINEGUN",
    "MOD_GRENADE",
    "MOD_GRENADE_SPLASH",
    "MOD_ROCKET",
    "MOD_ROCKET_SPLASH",
    "MOD_PLASMA",
    "MOD_PLASMA_SPLASH",
    "MOD_RAILGUN",
    "MOD_LIGHTNING",
    "MOD_BFG",
    "MOD_BFG_SPLASH",
    "MOD_WATER",
    "MOD_SLIME",
    "MOD_LAVA",
    "MOD_CRUSH",
    "MOD_TELEFRAG",
    "MOD_FALLING",
    "MOD_SUICIDE",
    "MOD_TARGET_LASER",
    "MOD_TRIGGER_HURT",
    "MISSIONPACK",
    "MOD_NAIL",
    "MOD_CHAINGUN",
    "MOD_PROXIMITY_MINE",
    "MOD_KAMIKAZE",
    "MOD_JUICED",
    "MOD_GRAP",
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
      elsif item[:title] != "InitGame:" && item[:title] != "ShutdownGame:" && game_init
        game_play_item << item
      elsif item[:title] == "ShutdownGame:"
        game_init = false
        game = { number: game_number, game_play: game_play_item }
        all_games << game

        game_play_item = []
        game_number += 1
      end
    end

    all_games
  end
end

# GameDataService.new.call