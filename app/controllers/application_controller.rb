class ApplicationController < ActionController::Base

 
  # include ActionController::MimeResponds
  # require 'ruby-graphviz'
    #protect_from_forgery with: :null_session for api
    def request_status(sender,recipient)
      friend_request = FriendRequest.where(user_id: sender.id).where(friend_id: recipient.id).first
      if friend_request
       friend_request.status
      else
        false
      end
  end

  def current_user
    user = User.find(session[:user_id]) if session[:user_id] 
  end

  helper_method :current_user
  # push variable to gon in order to make them available for js
  

  def SetJsVariables
    if current_user
       channel = current_user.id
       name = User.get_full_name(current_user)
       token = current_user.eventbrite_token 
    end
    gon.push({
    :authenticity_token => form_authenticity_token,
    :current_user_channel =>  channel,
    :publish_key =>  ENV['PUBLISH_KEY'],
    :subscribe_key =>  ENV['SUBSCRIBE_KEY'],
    :current_user_name => name,
    :eventbrite_token => token
   })
  end

  def generate_code
    code = SecureRandom.hex(10)
  end

  def generate_six_digit_code
    code = rand(100 ** 6)
  end

  def blocked_event?(request_user, event)
    setting = request_user.block_events.where(resource: event).first
    if setting
     blocked = setting.is_on
    else
      false
    end      
  end


  def event_chat_muted?(request_user, event)
    setting = request_user.mute_chat_for_events.where(resource: event).first
    if setting
      mute = setting.is_on
     else
       false
     end   
  end

  def blocked_user?(request_user, user)
    setting = request_user.block_users.where(resource: user).first
    if setting
      blocked = setting.is_on
     else
       false
     end     
  end


  def user_chat_muted?(request_user, user)
    setting = request_user.mute_chat_for_users.where(resource: user).first
    if setting
      mute = setting.is_on
     else
       false
     end   
  end

  def string_to_sym(string)
    string.parameterize.underscore.to_sym
  end

  helper_method :SetJsVariables
  helper_method :create_activity
  helper_method :generate_code

end
