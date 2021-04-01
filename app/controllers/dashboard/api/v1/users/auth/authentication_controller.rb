class Dashboard::Api::V1::Users::Auth::AuthenticationController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request, only: [:update_password]

   # POST /auth/login
  def login

    if !params[:email].blank? && !params[:password].blank?
     @user = User.authenticate(params[:email], params[:password])
          app = Assignment.where(role_id: 5).map {|assignment| assignment.user }.select { |e| e.email == params[:email]} 
          business = Assignment.where(role_id: 2).map {|assignment| assignment.user }.select { |e| e.email == params[:email]} 

      if @user
          profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "address" => jsonify_location(@user.location),
              "password" => @user.password,
              "device_token" => @user.device_token,
              "about" => @user.about,
              "is_subscribed" => @user.is_subscribed,
              "followers_count" => @user.followers.size,
              "profile_name" => @user.business_profile.profile_name,
              "contact_name" =>  @user.business_profile.contact_name,
              "display_name" =>  @user.business_profile.display_name,
              "website" => @user.business_profile.website,
              "description" => @user.business_profile.description,
              "vat_number" =>  @user.business_profile.vat_number,
              "charity_number" =>  @user.business_profile.charity_number,
              "is_charity" =>  @user.business_profile.is_charity,
              "youtube" => @user.social_media.youtube,
              "facebook" => @user.social_media.facebook,
              "instagram" => @user.social_media.instagram,
              "twitter" => @user.social_media.twitter,
              "linkedin" => @user.social_media.linkedin,
              "spotify" => @user.social_media.spotify,
              "phone_details" => @user.phone_details,
              "link_accounts" => {
                "app_users" => app,
                "business" => business
              }
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
