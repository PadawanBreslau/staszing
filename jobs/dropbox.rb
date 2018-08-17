require 'curb'
require 'redis'

SCHEDULER.every '24h', :first_in => 0 do |job|
  file_id = ENV['DROPBOX_FILE_ID']
  access_token = ENV['DROPBOX_TOKEN']

  c = Curl::Easy.http_post("https://api.dropboxapi.com/2/paper/docs/download") do |curl|
    curl.headers["Authorization"] = access_token
    curl.headers["Dropbox-API-Arg"] = {"doc_id": file_id ,"export_format": "markdown"}.to_json
    curl.headers['Content-Type'] = ''
    curl.headers['Content-Length'] = ''
    curl.verbose = true
  end

  previous_sentence_count = $redis.get("sentence_count").to_i
  current_sentence_count = c.body_str.split(".").count

  if $redis.get("last_check_date").to_i < Date.today.mjd
    @count = current_sentence_count - previous_sentence_count

    $redis.set("last_check_date", Date.today.mjd)
    $redis.set("sentence_count", current_sentence_count)
  else
    @count = previous_sentence_count
  end

  send_event('ksiazka_counter', current: @count)
end
