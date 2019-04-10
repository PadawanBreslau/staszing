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
      add_riding_time(act)
    elsif act["type"] == 'Run' || act["type"] == 'Hike'
      @run_sum += act["distance"] / 1000.0
      @run_time += act['moving_time']
      add_running_time(act)
    end
  end

  @avg_bike_speed = @bike_time > 0 ? (@bike_sum / (@bike_time / 3600.0)).round(2) : 0.0
  @avg_run_speed = @run_time > 0 ? (@run_sum / (@run_time / 3600.0)).round(2) : 0.0

  send_event('sport', { items: items, color: sport_color, unordered: true  })
end

def add_running_time(act)
  if not_logged?(act)
    all_run_sum = $redis.get('run_sum').to_f
    new_sum = all_run_sum +  (act["distance"] / 1000.0)
    $redis.set('run_sum',  new_sum)
    $redis.set("act_#{act['id']}", 1)
  end
end

def add_riding_time(act)
  if not_logged?(act)
    all_ride_sum = $redis.get('ride_sum').to_f
    new_sum = all_ride_sum +  (act["distance"] / 1000.0)
    $redis.set('ride_sum',  new_sum)
    $redis.set("act_#{act['id']}", 1)
  end
end

def not_logged?(act)
  $redis.get("act_#{act['id']}").nil?
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
    }
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
  activities.select{ |a| Time.parse(a["start_date"]) + (10*24*60*60) > Time.now }
end
