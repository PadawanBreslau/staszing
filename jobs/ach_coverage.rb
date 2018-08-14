#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'action_view'
require './helpers/color_helper'

include ActionView::Helpers::DateHelper
include ColorHelper

gitlab_uri = "https://gitlab.com/"

SCHEDULER.every '25m', :first_in => 2 do |job|
  gitlab_token =  ENV['GITLAB_TOKEN']
  uri = URI("#{gitlab_uri}api/v4/projects/3938540/repository/files/coverage%2F.last_run.json/raw?private_token=#{gitlab_token}&ref=master")
  response = Net::HTTP.get(uri)
  result = JSON.parse(response)['result']['covered_percent']
  send_event('ach_coverage', current: result)
end
