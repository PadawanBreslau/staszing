require 'httparty'

URL = 'https://habitica.com/api/v3/tasks/user'

SCHEDULER.every '18m', :first_in => 1 do |job|
  get_todos
  select_todos
  get_dailies
  select_dailies
  habit_color
  send_event('habitica_todos', { items: habit_items, color: habit_color, unordered: true  })
end

def habit_items
  @selected_todos.map do |st|
    {
      label: st["text"],
      value: distance_of_time_in_words_to_now(Time.parse(st["date"]))
    }
  end
end

def missed_items
  @missed_dailys.map do |st|
    {
      label: st["text"],
      value: "Too unfrequent"
    }
  end
end

def headers
{
  'x-api-user': ENV['HABITICA_USER_ID'],
  'x-api-key': ENV['HABITICA_API_TOKEN'],
  'Content-Type': 'application/json'
}
end

def get_todos
  url =  URL + "?type=todos"

  response = HTTParty.get(url, headers: headers)
  @todos = JSON.parse(response.body)
end

def get_dailies
  url =  URL + "?type=dailys"

  response = HTTParty.get(url, headers: headers)
  @dailys = JSON.parse(response.body)
end

def select_dailies
  each_day_dailys = @dailys["data"].select{|td| td["frequency"] == "daily" }
  @missed_dailys = each_day_dailys.select{|edd| missed_a_lot?(edd)}
end

def select_todos
  @selected_todos = @todos["data"].select{|td| urgent_todo(td) }
end

def missed_a_lot?(daily)
  values = daily["history"].map{|hist| hist["value"]}
  (drops(values) * 3) > values.size
end

def drops(values)
  @counter = 0
  (values.size-1).times do |i|
    @counter += 1 if(values[i+1] < values[i])
  end
  @counter
end

def habit_color
  min = @selected_todos.map{|s| Date.parse(s["date"]).mjd - Date.today.mjd}.min
  missed = @missed_dailys.count
  if min && min < 3 || missed > 1
    red
  elsif min && min < 5 || missed > 0
    blue
  else
    green
  end
end

def urgent_todo(td)
  !!td["date"] && !td["completed"] && td["priority"] > 1.0 && Date.parse(td["date"]).mjd - Date.today.mjd < 21
end
