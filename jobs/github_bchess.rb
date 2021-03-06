#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'action_view'
require 'octokit'
require './helpers/color_helper'

include ActionView::Helpers::DateHelper
include ColorHelper

SCHEDULER.every '90m', :first_in => 0 do |job|
  last_commit = Octokit.commits("visualitypl/bchess").first
  last_commit_time = last_commit[:commit][:author][:date]
  last_commit_msg = last_commit[:commit][:message]

  last_commit_time_h = distance_of_time_in_words_to_now(last_commit_time)

  color = color_bchess(last_commit_time)

  send_event('github_bchess',
  { items: [
      { label: 'Last commit', value: last_commit_time_h},
       { label: 'Commit', value: last_commit_msg}
      ], color: color, unordered: true  })
end

private

def color_bchess(time)
  time_diff = ((Time.now - time) / 3600).round
  if time_diff < 250
    green(time_diff/2)
  else
    red(time_diff/2)
  end
end
