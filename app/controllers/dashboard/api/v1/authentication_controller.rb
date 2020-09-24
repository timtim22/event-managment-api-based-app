class Dashboard::Api::V1::AuthenticationController < Dashboard::Api::V1::ApiMasterController 
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
      user_data = {}
      user_data['id'] =  @user.id,
      user_data['profile_name'] =  @user.business_profile.profile_name,
      user_data['avatar'] = @user.avatar,
      user_data['email'] = @user.email,
      user_data['contact_name']  = @user.business_profile.contact_name,
      user_data['address'] = @user.business_profile.address,
      user_data['vat_number'] = @user.business_profile.vat_number,
      user_data['charity_number']  = @user.business_profile.charity_number,
      user_data['website'] =  @user.business_profile.website,
      user_data['about'] =  @user.business_profile.about,
      user_data['phone_number']  = @user.phone_number
      # create_activity creates login issue regarding jwt auth token requirements
      #create_activity('logged in.', @user, 'User', '', '', 'post')
      token = encode(user_id: @user.id)
      render json: { 
            code: 200,
            success: true,
            message: "Login is successful.",
            data: {
              token: token,
              user: user_data
            }
          }
     else
      render json: { 
        code: 401,
        success: false,
        message: "Email/password is incorrect.",
        data: nil
      }
    end
  end

  end
    
end
