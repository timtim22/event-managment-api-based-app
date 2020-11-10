class Api::V1::AuthenticationController < Api::V1::ApiMasterController
  before_action :authorize_request, only: [:update_password]
  
   # POST /auth/login
   def login
    @empty = {}
   
    if params[:id].blank? == true
      render json: { 
        code: 400,
        success: false,
        message: "id number is required.",
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
    @user = User.find(params[:id])
    if @user
       if @user.app_user
        @profile_data = get_user_simple_object(@user)
        @user.profile.update!(device_token: params[:device_token])
       elsif @user.web_user
        @profile_data = get_business_simple_object(@user)
       end
      # create_activity creates login issue regarding jwt auth token requirements
      #create_activity('logged in.', @user, 'User', '', '', 'post')
      token = encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      
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
        message: "Email/password is incorrect.",
        data: @empty
      }
    end
  end

  end



 def get_accounts
    @phone_number = params[:phone_number]
    if params[:phone_number].blank? == true
      render json: { 
        code: 400,
        success: false,
        message: "Phone number is required.",
        data: nil
       }
    else
    @accounts = User.where(phone_number: @phone_number)
       business_accounts = []
       app_account = {}
       accounts_data = {}
    if !@accounts.blank?
      @accounts.each do |account|
        if account.web_user
          obj = {
            "id" => account.id,
            "profile_name" => account.business_profile.profile_name,
            "avatar" => account.avatar,
            "phone_number" => account.phone_number,
            "web_user" => account.web_user,
            "app_user" => account.app_user,
            "email" => account.email
          }
         business_accounts.push(obj)
        else account.app_user
         account.profile.update!(device_token: params[:device_token])
         app_account =  {
          "id" => account.id,
          "first_name" => account.profile.first_name,
          "last_name" => account.profile.last_name,
          "avatar" => account.avatar,
          "phone_number" => account.phone_number,
          "web_user" => account.web_user,
          "app_user" => account.app_user,
          "email" => account.email
         }
        end        
      end #each
    
    end

      accounts_data['business'] = business_accounts
      accounts_data['app'] = app_account

    render json: { 
      code: 200,
      success: true,
      message: "",
      data: {
         accounts: accounts_data
       }
    }
  end

  end #func

  

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
          UserMailer.welcome_email(@user).deliver_now
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
