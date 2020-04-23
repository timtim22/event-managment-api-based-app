json.notifications do
  json.array!(@notifications) do |notification|
  json.id notification.id
  json.unread_notification_count current_user.notifications.unread.size
  json.unread !notification.read_at?
  json.recipient notification.recipient
  json.actor_avatar  notification.actor.avatar.url
  json.notification_url notification.url
  json.image_link notification.actor.image_link
  json.time time_ago_in_words(notification.created_at)
  json.actor notification.actor.first_name + ' ' + notification.actor.last_name 
  json.action notification.action
  json.notification_notifiable_type notification.notifiable_type
  end
end