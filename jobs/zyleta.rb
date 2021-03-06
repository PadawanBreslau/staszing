#!/usr/bin/env ruby

SCHEDULER.every '1d', at: '2am', first_in: 0 do |job|
  zyleta_date = Date.new(2019, 6, 8)
  today = Date.today

  days_till = zyleta_date.mjd - today.mjd

  send_event('zyleta_counter', current: days_till, color: zyleta_color(days_till))
end

def zyleta_color(date_till)
  if date_till > 100
    green(120-date_till)
  elsif date_till > 50
    blue
  else
    red
  end
end
