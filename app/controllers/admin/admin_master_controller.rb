class Admin::AdminMasterController < ApplicationController
before_action :require_signin, except: [:new,:create,:send_email_page,:send_reset_email,:reset_password_page,:reset_password]
#before_action :require_phone_verification, except: [:new, :create]
before_action :SetJsVariables
# Admin master logic goes here

def require_phone_verification
  if current_user && current_user.phone_verified != true
    redirect_to verify_phone_path
  end
end

def require_signin
    unless current_user
       if request.xhr?
        session[:intended_request] = request.base_url + "/admin/dashboard"
       else
        session[:intended_request] = request.url
       end
        redirect_to new_admin_session_path, notice: "Login is required."
    end
end

def correct_user?(user)
    unless current_user == user
     redirect_to root_url 
    end
end

## Friendship module


def get_friend_from_request(request)
  friend = User.find(request.friend_id)
end

def create_activity(action, resource, resource_type, resource_url,resrource_title, method)
  ActivityLog.create(user: current_user, action: action, resource: resource, resource_type: resource_type, browser: request.env['HTTP_USER_AGENT'], ip_address: request.env['REMOTE_ADDR'], params: params.inspect,url: resource_url, method: method, resource_title: resrource_title)  
end

helper_method :correct_user?
helper_method :get_friend_from_request

end