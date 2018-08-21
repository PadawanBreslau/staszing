require 'steam-api'

SCHEDULER.every '35m', :first_in => 1 do |job|
  Steam.apikey = ENV['STEAM_KEY']
  steamid = ENV['STEAMID']

  games = Steam::Player.recently_played_games(steamid)
  items = []
  sum = 0
  games["games"]&.each do |game|
     val = {
       label: game["name"],
       value: humanize(game["playtime_2weeks"])
     }
     sum += game["playtime_2weeks"]
     items << val
  end
  send_event('steam', { items: items, color: steam_color(sum), unordered: true  })
end

def humanize(val)
  distance_of_time_in_words(0, val*60)
end

def steam_color(sum)
  if sum < 600
    green(sum/10)
  else
    red(sum/10)
  end
end
