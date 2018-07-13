#!/usr/bin/env ruby

SCHEDULER.every '10m', :first_in => 3 do |job|
  key = ENV['ROLLBAR_KEY']
  uri = URI("https://api.rollbar.com/api/1/items?access_token=#{key}&status=active")
  errors = rollbar_errors(uri)
  analyze(errors)

  items = errors.map{ |e| {label: e["title"][0..120], value: e["counter"]} }

  send_event('rollbar', { items: items, color: @color })
end

def rollbar_errors(uri)
  response = Net::HTTP.get(uri)
  JSON.parse(response)["result"]["items"].select{ |e| e["status"] == 'active' }
rescue StandardError
  []
end

def analyze(errors)
  if recent_error?(errors)
    @color = red
  elsif lots_of_errors?(errors)
    @color = purple(err.size)
  elsif lots_of_occurences?(errors)
    @color = blue(@count)
  else
    @color = green
  end
rescue NoMethodError
  @color = green
end

def recent_error?(errs)
  errs.any?{ |e| ((Time.now.to_i - e["first_occurrence_timestamp"]) / 3600.0).round < 24 }
end

def lots_of_errors?(errs)
  errs.size > 10
end

def lots_of_occurences?(errs)
  (@count = errs.map { |e|  e["total_occurrences"] }.reduce(:+)) > 100
end
