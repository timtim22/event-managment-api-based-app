module ApplicationHelper

  def get_full_name(user)
    if is_mobile_user?(user)
      name = user.profile.first_name + " " + user.profile.last_name
    elsif(user.web_user ==  true)
      name = user.business_profile.profile_name
    end
  end



end