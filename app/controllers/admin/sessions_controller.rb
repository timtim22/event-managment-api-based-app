class Admin::SessionsController < Admin::AdminMasterController

    def create
    if  user = User.authenticate(params[:email], params[:password])
      if !is_business?(user)
        flash.now[:alert_danger] = "App user can not be logged in via web interface."
        render :new
      end
      session[:user_id] = user.id
      #create_activity("signed in", user, "User", '','', 'post', 'signed_in')
			redirect_to session[:intended_request] || admin_dashboard_path
         else
         	flash.now[:alert_danger] = "Either username or password is incorrect!"
         	render :new
         end
      	end

    def destroy
        session[:user_id] = nil
        redirect_to new_admin_session_path, notice: "You are signed out."
    end
end
