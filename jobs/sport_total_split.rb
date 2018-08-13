#!/usr/bin/env ruby

SCHEDULER.every '15m', :first_in => 0 do |job|
  send_event('sport_total_split', { items: split_items })
end


def split_items
  [
    {
      label: 'Bike',
      value: "#{$redis.get('ride_sum').to_f / 3.0} km"
    },
    {
      label: 'Walk/Run',
      value: "#{$redis.get('run_sum').to_f} km"
    }
  ]
end
