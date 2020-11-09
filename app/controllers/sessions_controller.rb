class SessionsController < ApplicationController

    def create
		if  user = User.authenticate(params[:email], params[:password])
			session[:user_id] = user.id
			session[:flash] = "Welome back #{user.name}"
			redirect_to session[:intended_request] || admin_dashboard_path
         else
         	flash.now[:alert] = "Either username or password is incorrect!"
         	render :new
         end
      	end

    def destroy
        session[:user_id] = nil
        redirect_to new_session_path, notice: "You are signed out."
    end
end
