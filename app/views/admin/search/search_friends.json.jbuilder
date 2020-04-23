json.friends do
  json.array!(@friends) do |friend|
    json.first_name friend.first_name
    json.last_name friend.last_name
    json.url "/admin/add-friend?id=#{friend.id}" 
    json.avatar friend.avatar.url
    json.current_user_id  current_user.id
    json.friend_id friend.id
    json.is_friend is_friend?(friend.id)
  end
end