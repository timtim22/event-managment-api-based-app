module UsersHelper
  def InfoData(user)
      user_info = {}
    if user.business_profile
       user_info['about'] = user.business_about
       user_info['facebook'] = user.business_profile.facebook
       user_info['twitter'] = user.business_profile.twitter
       user_info['linkedin'] = user.business_profile.linkedin
       user_info['instagram'] = user.business_profile.instagram 
    else
      user_info ['about'] = "No record" 
      user_info ['add_social_media_links'] = "No record"
      user_info['facebook'] = "No record"
      user_info['twitter'] = "No record"
      user_info['linkedin'] = "No record"
      user_info['instagram'] = "No record" 
    end
    user_info
  end

  def is_friend?(friend_id)
    friend_request = FriendRequest.where(friend_id: friend_id).where(status: 'accepted').first
    if friend_request
      if friend_request.friend_id == current_user.id
       "you"
      else
      true
      end
    else
      false
    end
  end

   def get_user_avatar(user)
    if !user.avatar.blank?
    src = asset_path "#{user.avatar}"
    else
      src = asset_path "#{user.image_link}"
    end
   end

  def getRoles
    @roles = []
     role_ids = [1,2]
     role_ids.each do |id|
    @roles.push(Role.find(id))
   end
   @roles
   end

   def full_name(user)
    user.first_name + " " + user.last_name
   end

end
