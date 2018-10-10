require 'curb'

SCHEDULER.every '24h', :first_in => 0 do |job|
  url = 'https://www.facebook.com/events/146913979259012/'

  c = Curl::Easy.new(url)
  c.headers["User-Agent"] = "staszing"
  c.perform

  interested_count = 57

  send_event('krazownik', current: interested_count)
end
