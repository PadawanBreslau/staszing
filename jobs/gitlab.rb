#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'action_view'
require './helpers/color_helper'

include ActionView::Helpers::DateHelper
include ColorHelper

gitlab_uri = "https://gitlab.com/"

SCHEDULER.every '25m', :first_in => 0 do |job|
  gitlab_token =  ENV['GITLAB_TOKEN']
  uri = URI("#{gitlab_uri}api/v4/projects/3938540/events?private_token=#{gitlab_token}")
  uri_fr = URI("#{gitlab_uri}api/v4/projects/9600353/events?private_token=#{gitlab_token}")

  response = Net::HTTP.get(uri)
  events_b = JSON.parse(response)

  response_fr = Net::HTTP.get(uri_fr)
  events_fr = JSON.parse(response)

  events = events_b + events_fr

  last_push = events.select{|e| e["action_name"] == 'pushed to'}.first["created_at"]
  last_push_h = distance_of_time_in_words_to_now(Time.parse(last_push))

  uri_commit = URI("#{gitlab_uri}api/v4/projects/3938540/repository/commits?private_token=#{gitlab_token}")
  response = Net::HTTP.get(uri_commit)
  commit_b = JSON.parse(response).first

  uri_commit_fr = URI("#{gitlab_uri}api/v4/projects/9600353/repository/commits?private_token=#{gitlab_token}")
  response = Net::HTTP.get(uri_commit_fr)
  commit_fr = JSON.parse(response).first

  commit = commit_b["created_at"] > commit_fr["created_at"] ? commit_b : commit_fr

  last_commit_time =  commit["created_at"]
  last_commit_time_h = distance_of_time_in_words_to_now(Time.parse(last_commit_time))
  last_commit_msg = commit["message"]

  color = color(Time.parse(last_commit_time))

  send_event('gitlab',
    { items: [{ label: 'Last push', value: last_push_h},
        { label: 'Last commit', value: last_commit_time_h},
         { label: 'Commit', value: last_commit_msg}
        ], color: color, unordered: true })
end

def color(time)
  time_diff = ((Time.now - time) / 3600).round
  if time_diff < 125
    green(time_diff*2)
  else
    red(time_diff*2)
  end
end
