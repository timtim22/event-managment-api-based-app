class Dashboard::Api::V1::AuthenticationController < Api::V1::ApiMasterController
  before_action :authorize_request, only: [:update_password]
  
   # POST /auth/login
   def login
    
    if params[:email].blank? == true
      render json: { 
        code: 400,
        success: false,
        message: "Email is required.",
        data: nil
       }

      elsif params[:password].blank? == true 
        render json: {
          code: 400, 
          success: false,
          message: "Password is required.",
          data: nil
         }
    else
      @user = User.authenticate(params[:email], params[:password])
    if @user
      # create_activity creates login issue regarding jwt auth token requirements
      #create_activity('logged in.', @user, 'User', '', '', 'post')
      token = encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      @user.device_token = params[:device_token]
      @user.save()
      render json: { 
            code: 200,
            success: true,
            message: "Login is successful.",
            data: {
              token: token,
              user: @user
            }
          }
     else
      render json: { 
        code: 401,
        success: false,
        message: "login failed.Please check your credentials.",
        data: nil
      }
    end
  end

  end
    
end
