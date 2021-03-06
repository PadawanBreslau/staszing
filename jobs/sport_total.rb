#!/usr/bin/env ruby

SCHEDULER.every '15m', :first_in => 1 do |job|
  left_km = 4800.0 - ($redis.get('ride_sum').to_f / 3.0 + $redis.get('run_sum').to_f).round(3)
  send_event('sport_total', { text: left_km.to_s + " km", color: sport_total_color(left_km) })
end

def days_till_b
  b7s_date = Date.new(2020, 7, 23)
  today = Date.today

  days_till = b7s_date.mjd - today.mjd
end

def sport_total_color(left_km)
  if left_km/days_till_b < 6.5
    green
  elsif left_km/days_till_b > 7.2
    red
  else
    blue
  end
end
