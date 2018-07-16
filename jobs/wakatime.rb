#!/usr/bin/env ruby
require 'wakatime'

SCHEDULER.every '12m', :first_in => 0 do |job|
  @session = Wakatime::Session.new({
      api_key: ENV['WAKA_KEY']
  })

  durations = []
  @client = Wakatime::Client.new(@session)

  0.upto(6) do |i|
    durations.concat @client.durations(Date.today - i)
  end

  projects = Hash.new(0)

  durations.each do |duration|
    project = duration['project']
    time = duration['duration']

    projects[project] += time.round
  end

  projects.delete_if{|_, v| v < 300 }

  send_event('wakatime', {labels: projects.keys, datasets: projects.values.map{|v| (v/60).round} })
end
