class Dashboard::Api::V1::Users::Auth::AuthenticationController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request, only: [:update_password]

   # POST /auth/login
  def login

    if !params[:email].blank? && !params[:password].blank?
     @user = User.authenticate(params[:email], params[:password])
      if @user
          profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "password" => @user.password,
              "location" => @user.location,
              "about" => @user.about,
              "is_subscribed" => @user.is_subscribed,
              "followers_count" => @user.followers.size,
              "profile_name" => @user.business_profile.profile_name,
              "contact_name" =>  @user.business_profile.contact_name,
              "display_name" =>  @user.business_profile.display_name,
              "website" => @user.business_profile.website,
              "vat_number" =>  @user.business_profile.vat_number,
              "charity_number" =>  @user.business_profile.charity_number,
              "youtube" => @user.social_media.youtube,
              "facebook" => @user.social_media.facebook,
              "instagram" => @user.social_media.instagram,
              "twitter" => @user.social_media.twitter,
              "linkedin" => @user.social_media.linkedin
          }

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
    else
      render json: {
        code: 400,
        success: false,
        message: "Email and password are required.",
        data: nil
       }
  end

  end

end
