json.array! @notifications do |notification|
  json.id notification.id
  json.unread !notification.read_at?
  #json.recipient notification.recipient
  #json.actor notification.actor.first_name + ' ' + notification.actor.last_name 
  #json.action notification.action
end