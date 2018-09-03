SCHEDULER.every '1m', first_in: 0 do
  uri = URI.parse(ENV['HEALTH_CHECK_API_URL'])
  result = Net::HTTP.get_response(uri)

  status = if result.code == '200'
    @color = green
    true
  else
    @color = red
    false
  end

  send_event('health_check', { status: status, color: @color })
end
