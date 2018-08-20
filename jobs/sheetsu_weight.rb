require 'sheetsu'

SCHEDULER.every '4h', :first_in => 3 do |job|
  api_key = ENV['SHEETSU_KEY']
  api_secret = ENV['SHEETSU_SECRET']
  doc_key = ENV['SHEETSU_DOC']

  client = Sheetsu::Client.new(
    doc_key,
    api_key: api_key,
    api_secret: api_secret
  )
  data = client.read

  weight = data.select{|d| d["weight"].present? }.last(5)

  send_event("weight", {
    labels: weight.map{|w| w["date"]},
    datasets: weight.map{|w| w["weight"]}
    })
  end
