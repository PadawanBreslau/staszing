#!/usr/bin/env ruby
require 'strava/api/v3'

SCHEDULER.every '65m', :first_in => 0 do |job|
  access_token = ENV['STRAVA_TOKEN']
  client = client(access_token)
  my_activities = client.list_athlete_activities
  recent_activities = recent(my_activities)

  @run_sum = 0.0
  @bike_sum = 0.0
  @run_time = 0.0
  @bike_time = 0.0

  recent_activities.each do |act|
    if act["type"] == 'Ride'
      @bike_sum += act["distance"] / 1000.0
      @bike_time += act['moving_time']
    elsif act["type"] == 'Run'
      @run_sum += act["distance"] / 1000.0
      @run_time += act['moving_time']
    end
  end

  @avg_bike_speed = @bike_time > 0 ? (@bike_sum / (@bike_time / 3600.0)).round(2) : 0.0
  @avg_run_speed = @run_time > 0 ? (@run_sum / (@run_time / 3600.0)).round(2) : 0.0


  send_event('sport', { items: items, color: sport_color })
end

def items
  [
    {
      label: 'Bike',
      value: "#{@bike_sum.round(3)} km"
    },
    {
      label: 'Walk/Run',
      value: "#{@run_sum.round(3)} km"
    },
    {
      label: 'AVG Bike speed',
      value: "#{@avg_bike_speed} km/h"
    },
    {
      label: 'AVG Walk speed',
      value: "#{@avg_run_speed} km/h"
    },
  ]
end

def sport_color
  count = (@bike_sum + @run_sum*3).to_i
  if count > 120
    green((200-count).abs)
  elsif count > 60
    blue(60-count)
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
