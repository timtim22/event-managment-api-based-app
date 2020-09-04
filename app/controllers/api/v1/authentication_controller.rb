class Api::V1::AuthenticationController < Api::V1::ApiMasterController
  before_action :authorize_request, only: [:update_password]
  
   # POST /auth/login
   def login
    @empty = {}
    @phone_number = params[:phone_number]
    if params[:phone_number].blank? == true
      render json: { 
        code: 400,
        success: false,
        message: "Phone number is required.",
        data: nil
       }

      elsif params[:device_token].blank? == true 
        render json: {
          code: 400, 
          success: false,
          message: "Device token is required.",
          data: nil
         }
    else
    @user = User.find_by(phone_number: @phone_number)
    if @user
      @profile_data = {}
      @profile_data['id'] = @user.id
      @profile_data["first_name"] = @user.profile.first_name
      @profile_data["last_name"] = @user.profile.last_name
      @profile_data["avatar"] = @user.avatar
      # create_activity creates login issue regarding jwt auth token requirements
      #create_activity('logged in.', @user, 'User', '', '', 'post')
      token = encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      @user.profile.update!(device_token: params[:device_token])
      render json: { 
            code: 200,
            success: true,
            message: "Login is successful.",
            data: {
              token: token,
              user: @profile_data
            }
          }
     else
      render json: { 
        code: 401,
        success: false,
        message: "login failed.Please check your credentials.",
        data: @empty
      }
    end
  end

  end

  

  def logout
     header = request.headers['Authorization']
     token = header.split(' ').last if header
     session[:logout] = token
     response = {
       code: 200,
       success: true,
       message: "Logout seccessfully.",
       data: nil
     }
     render json: response.to_json
  end

  # def send_verification_email 
  #   @user = User.find_by(email: params[:email])
  #   @code = (SecureRandom.random_number(9e5) + 1e5).to_i
  #   @user.verification_code = @code
  #   if @user.save()
  #     @url = "#{ENV['BASE_URL']}/api/v1/auth/verify-code?verification_code=#{@code}"
  #  if UserMailer.with(user: @user).verification_email(@user,@url).deliver_now#UserMailer.verification_email(user).deliver_now
  #    response = {
  #       code: 200,
  #       success: true,
  #       message: "Email sent successfully",
  #       data: nil
  #    }
  #    render json: response.to_json
  #   else
  #     response = {
  #        code: 400,
  #        success: false,
  #        message: "Email couldnt be sent.",
  #        data: nil
  #     }
  #     render json: response.to_json
  #   end
  #   end
  # end

  def verify_code
    @user = User.find_by(email: params[:email])
    if @user
    if @user.verification_code == params[:verification_code]
        @user.update!(is_email_verified: true)
        flash.now[:notice] = "Email verified successfully. Thanks for the verification."
        render ('user_mailer/verifciation_redirect_page')
    else
      flash.now[:alert_danger] = "Verification code didn't match."
      render :verifciation_redirect_page
    end
  else
    flash.now[:alert_danger] = "We couldn't find user associated with this email."
    render ('user_mailer/verifciation_redirect_page')
  end
  end

  def update_password
    @user = User.find_by(email: params[:email])
    @user.password = params[:password]
    if @user.save()
      response = {
        code: 200,
        success: true,
        message: "Password updated successfully.",
        data: nil
      }
      render json: response.to_json
    else
      response = {
        code: 400,
        status: false,
        message: @user.errors.full_messages,
        data: nil
      }
      render json: response.to_json
    end
  end

  private

  def login_params
    params.permit(:email, :password)
  end
   
end
