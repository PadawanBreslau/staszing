#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'action_view'
require './helpers/color_helper'

include ActionView::Helpers::DateHelper
include ColorHelper

gitlab_token = "c_ym3dVsG-sG6zRsxJXy"
gitlab_uri = "https://gitlab.com/"

SCHEDULER.every '30m', :first_in => 0 do |job|
  uri = URI("#{gitlab_uri}api/v4/projects/3938540/events?private_token=#{gitlab_token}")
  response = Net::HTTP.get(uri)
  events = JSON.parse(response)

  last_push = events.select{|e| e["action_name"] == 'pushed to'}.first["created_at"]
  last_push_h = distance_of_time_in_words_to_now(Time.parse(last_push))

  uri_commit = URI("#{gitlab_uri}api/v4/projects/3938540/repository/commits?private_token=#{gitlab_token}")
  response = Net::HTTP.get(uri_commit)
  commit = JSON.parse(response).first

  last_commit_time =  commit["created_at"]
  last_commit_time_h = distance_of_time_in_words_to_now(Time.parse(last_commit_time))
  last_commit_msg = commit["message"]

  color = color(Time.parse(last_commit_time))

  send_event('gitlab',
    { items: [{ label: 'Last push', value: last_push_h},
        { label: 'Last commit', value: last_commit_time_h},
         { label: 'Commit', value: last_commit_msg}
        ], color: color })
end

def color(time)
  time_diff = ((Time.now - time) / 3600).round
  if time_diff < 125
    green(time_diff*2)
  else
    red(time_diff*2)
  end
end
