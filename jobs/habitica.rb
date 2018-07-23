require 'httparty'

URL = 'https://habitica.com/api/v3/tasks/user'

SCHEDULER.every '18m', :first_in => 1 do |job|
  get_todos
  select_todos
  habit_color
  send_event('habitica_todos', { items: habit_items, color: habit_color })
end

def habit_items
  @selected_todos.map do |st|
    {
      label: st["text"],
      value: distance_of_time_in_words_to_now(Time.parse(st["date"]))
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

def select_todos
  @selected_todos = @todos["data"].select{|td| urgent_todo(td) }
end

def habit_color
  min = @selected_todos.map{|s| Date.parse(s["date"]).mjd - Date.today.mjd}.min
  if min && min < 3
    red
  elsif min && min < 5
    blue
  else
    green
  end
end

def urgent_todo(td)
  !!td["date"] && !td["completed"] && td["priority"] > 1.0 && Date.parse(td["date"]).mjd - Date.today.mjd < 21
end
