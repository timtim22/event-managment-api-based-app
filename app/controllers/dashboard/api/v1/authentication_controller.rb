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
          social_links = {
            "youtube" => @user.business_profile.youtube,
            "facebook" => @user.business_profile.facebook,
            "instagram" => @user.business_profile.instagram,
            "twitter" => @user.business_profile.twitter,
            "linkedin" => @user.business_profile.linkedin
          }


          profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "password" => @user.password,
              "followers_count" => @user.followers.size,
              "profile_name" => @user.business_profile.profile_name,
              "contact_name" =>  @user.business_profile.contact_name,
              "display_name" =>  @user.business_profile.display_name,
              "address" => @user.business_profile.address,
              "website" => @user.business_profile.website,
              "about" =>  @user.business_profile.about,
              "vat_number" =>  @user.business_profile.vat_number,
              "social_links" => social_links

          }
      # create_activity creates login issue regarding jwt auth token requirements
      #create_activity('logged in.', @user, 'User', '', '', 'post')
      token = encode(user_id: @user.id)
      render json: {
            code: 200,
            success: true,
            message: "Login is successful.",
            data: {
              token: token,
              user: profile
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
