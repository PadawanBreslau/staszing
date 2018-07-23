#!/usr/bin/env ruby

SCHEDULER.every '1d', at: '2am', first_in: 0 do |job|
  b7s_date = Date.new(2020, 7, 23)
  today = Date.today

  days_till = b7s_date.mjd - today.mjd

  send_event('b7s_counter', current: days_till)
end
