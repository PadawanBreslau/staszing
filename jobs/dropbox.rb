require 'curb'
require 'redis'

SCHEDULER.every '24h', :first_in => 0 do |job|
  file_id = ENV['DROPBOX_FILE_ID']
  access_token = ENV['DROPBOX_TOKEN']

  file_id = "9MhXzGfWtbQMdQZRRGpEa"
  access_token = 'Bearer ddd2_uC7tZ4AAAAAAAADMM9GZPNJWagtT8st2YkZZUOjjmykeV6gkjIIdp2Q65k5'

  c = Curl::Easy.http_post("https://api.dropboxapi.com/2/paper/docs/download") do |curl|
    curl.headers["Authorization"] = access_token
    curl.headers["Dropbox-API-Arg"] = {"doc_id": "9MhXzGfWtbQMdQZRRGpEa","export_format": "markdown"}.to_json
    curl.headers['Content-Type'] = ''
    curl.headers['Content-Length'] = ''
    curl.verbose = true
  end

  prev_new_sentence_count = $redis.get("sentence_count").to_i

  if $redis.set("last_check_date").to_i < Date.today.mdj
    sentence_count = c.body_str.split(".").count

    @count = sentence_count - prev_new_sentence_count

    $redis.set("last_check_date", Date.today.mdj)
    $redis.set("sentence_count", sentence_count)
  else
    @count = prev_new_sentence_count
  end

  send_event('ksiazka_counter', current: @count)
end
