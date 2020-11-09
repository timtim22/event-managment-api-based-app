json.array! @notifications do |notification|
  json.id notification.id
  json.unread !notification.read_at?
  #json.recipient notification.recipient
  #json.actor get_full_name(notification.actor)
  #json.action notification.action
end