require 'wykop'

SCHEDULER.every '8m', :first_in => 1 do |job|
  cl = Wykop::Client.new(app_key: ENV['WYKOP_APP'], app_secret: ENV['WYKOP_SECRET'])
  cl.login(username: 'Ragnarokk', accountkey: ENV['WYKOP_ACCOUNT'] )

  user = Wykop::User.new(cl)
  factor = wykop_factor(user)

  send_event('wykop_factor', current: factor , color: wypok_color(factor))
end

def wykop_factor(user)
  entries = user.entries
  comments = user.comments

  recent_entries = entries.select{|e| Time.parse(e["date"]) > Time.now - 3 * 24 * 3600}.size.to_f
  recent_comments = comments.select{|e| Time.parse(e["date"]) > Time.now - 3 * 24 * 3600}.size.to_f

  double_recent_entries = entries.select{|e| Time.parse(e["date"]) > Time.now - 6 * 24 * 3600}.size.to_f
  double_recent_comments = comments.select{|e| Time.parse(e["date"]) > Time.now - 6 * 24 * 3600}.size.to_f

  if recent_entries + recent_comments > 2.0
    ((recent_entries/double_recent_entries + 2.0 * recent_comments/double_recent_comments) / 3.0).round(2)
  else
    0.0
  end
end

def wypok_color(factor)
  if factor > 0.8
    red
  elsif factor > 0.5
    blue
  else
    green
  end
end
