#!/usr/bin/env ruby
require 'strava/api/v3'

SCHEDULER.every '30m', :first_in => 0 do |job|
  access_token = 'd60bfec96d033f008641de4c628f02feefe2be3e'
  client = client(access_token)
  my_activities = client.list_athlete_activities
  recent_activities = recent(my_activities)

  @run_sum = 0.0
  @bike_sum = 0.0

  recent_activities.each do |act|
    if act["type"] == 'Ride'
      @bike_sum += act["distance"] / 1000.0
    elsif act["type"] == 'Run'
      @run_sum += act["distance"] / 1000.0
    end
  end

  send_event('sport', { items: items, color: sport_color })
end

def items
  [
    {
      label: 'Bike',
      value: "#{@bike_sum} km"
    },
    {
      label: 'Walk/Run',
      value: "#{@run_sum} km"
    }
  ]
end

def sport_color
  count = (@bike_sum + @run_sum*3).to_i
  if count > 120
    green((200-count).abs)
  elsif count > 80
    blue(80-count)
  else
    red(120-count)
  end
end

def client(token)
  @client ||= Strava::Api::V3::Client.new(access_token: token)
end

def recent(activities)
  activities.select{ |a| Time.parse(a["start_date"]) + (7*24*60*60) > Time.now }
end
