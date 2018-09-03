require 'sheetsu'
require 'fuzzystringmatch'

HEALTH_ONE_FOOD = ['banan', 'jajko na miekko', 'kanapka razowy', 'guacamole', 'herbata']
HEALTH_TWO_FOOD = ['kanapka ser', 'spaghetti', 'ryba', 'jablko', 'jogurt owocowy']
HEALTH_THREE_FOOD = ['jajecznica', 'burrito', 'ryba w panierce', 'tortilla kurczak']
HEALTH_FOUR_FOOD = ['parówki', 'tosty', 'pizza', 'parowki', 'ciasto']
HEALTH_FIVE_FOOD = ['racuchy']

@jarow = FuzzyStringMatch::JaroWinkler.create( :native )

SCHEDULER.every '2h', :first_in => 3 do |job|
  api_key = ENV['SHEETSU_KEY']
  api_secret = ENV['SHEETSU_SECRET']
  doc_key = ENV['SHEETSU_DOC']

  client = Sheetsu::Client.new(
    doc_key,
    api_key: api_key,
    api_secret: api_secret
  )
  data = client.read

  food = data.select{|d| d["food"].present? }.last['food']
  factor = food_factor(food).round(2)

  send_event('food', current: factor, color: food_color(factor))
end

def food_color(factor)
  if factor > 3.0
    red
  elsif factor > 1.25
    blue
  else
    green
  end
end

def food_factor(food)
  split_food = food.split(',')

  return 0.0 if split_food.empty?

  result = 0.0
  split_food.each do |f|
    if include_similar?(HEALTH_ONE_FOOD, f)
      result += 0.5
    elsif include_similar?(HEALTH_TWO_FOOD, f)
      result += 1.0
    elsif include_similar?(HEALTH_THREE_FOOD, f)
      result += 2.0
    elsif include_similar?(HEALTH_FOUR_FOOD, f)
      result += 4.0
    elsif include_similar?(HEALTH_FIVE_FOOD, f)
      result += 8.0
    else
      puts "ADD #{f} to list!"
    end
  end
  result / split_food.size
end

def include_similar?(set, val)
  set.include?(val.strip) || set.any?{|s| similar?(s, val)}
end

def similar?(s, val)
  @jarow.getDistance(s, val) > 0.825
end
