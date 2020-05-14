class ApplicationController < ActionController::Base

 
  # include ActionController::MimeResponds
  # require 'ruby-graphviz'
    #protect_from_forgery with: :null_session for api
    def request_status(sender,recipient)
      friend_request = FriendRequest.where(user_id: sender.id).where(friend_id: recipient.id).first
      if friend_request
       friend_request.status
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
    code = SecureRandom.hex
   end

  helper_method :SetJsVariables
  helper_method :create_activity
  helper_method :generate_code

end
