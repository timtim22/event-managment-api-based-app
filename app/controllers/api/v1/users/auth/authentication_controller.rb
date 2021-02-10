class Api::V1::Users::Auth::AuthenticationController < Api::V1::ApiMasterController
  before_action :authorize_request, only: [:update_password]
  require 'pubnub'
   # POST /auth/login

    api :POST, '/api/v1/auth/login', 'To login and Generate Auhtorization Token'
    param :uuid, String, :desc => "The ID of the user", :required => true
    param :device_token, String, :desc => "pass any string ", :required => true

   def login
     if params[:uuid].present? && params[:device_token].present?
         user = User.find_by(uuid: params[:uuid])
         if user
            token = get_token_from_user(user)
            @profile_data = {
              id: user.id,
              email: user.email,
              avatar: user.avatar,
              phone_number: user.phone_number,
              about: user.about
            }

            if update = user.update!(device_token: params[:device_token])
              render json: {
                code: 200,
                success: true,
                message: 'Login is successful.',
                data: {
                  token: token,
                  user:  @profile_data
                }
              }
            else
              render json: {
                code: 400,
                success: false,
                message: update.errors.full_messages,
                data: nil
              }
            end
        else
          render json: {
            code: 400,
            success: false,
            message: "Couldnt find user with the id #{params[:uuid]}.",
            data: nil
          }
        end
     else
      render json: {
        code: 400,
        success: false,
        message: "uuid and device_token are required field.",
        data: nil
      }
     end
   end




  api :POST, '/api/v1/auth/get-accounts', 'To get user account list'
  param :phone_number, String, :desc => "Phone Number", :required => true


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
        if account.role_ids.include?(2)
          obj = {
            "id" => account.id,
            "uuid" => account.uuid,
            "profile_name" => account.business_profile.profile_name,
            "contact_name" => account.business_profile.contact_name,
            "display_name" => account.business_profile.display_name,
            "avatar" => account.avatar,
            "phone_number" => account.phone_number,
            "email" => account.email
          }
         business_accounts.push(obj)
        else account.role_ids.include?(5)
         app_account =  {
          "id" => account.id,
          "first_name" => account.profile.first_name,
          "last_name" => account.profile.last_name,
          "dob" => account.profile.dob,
          "gender" => account.profile.gender,
          "avatar" => account.avatar,
          "phone_number" => account.phone_number,
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



  # def logout_old
  #    header = request.headers['Authorization']
  #    token = header.split(' ').last if header
  #    session[:logout] = token
  #    response = {
  #      code: 200,
  #      success: true,
  #      message: "Logout seccessfully.",
  #      data: nil
  #    }
  #    render json: response.to_json
  # end

  api :POST, '/api/v1/auth/logout', 'To logout'
  param :phone_number, String, :desc => "Phone Number", :required => true

  def logout
    if params[:phone_number].present?
        accounts = User.where(phone_number: params[:phone_number])
        errors = []
        accounts.each do |acc|
          if update = acc.update!(device_token: "token_removed")
             "OK"
          else
            errors = update.errors.full_messages
          end
        end #each
      
    if  errors.blank?
      render json: {
        code: 200,
        success: true,
        message: 'Logout successfully.',
        data: nil
      }
   else
    render json: {
        code: 400,
        success: false,
        message: errors,
        data: nil 
    }
   end
  else
    render json: {
      code: 400,
      success: false,
      message: "phone_number is required field.",
      data: nil
    }
  end
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

  # api :POST, '/api/v1/auth/verify_code', 'Code verification code'
  # param :email, String, :desc => "Email", :required => true
  # param :verification_code, String, :desc => "Verification code", :required => true

  # def verify_code
  #   @user = User.find_by(email: params[:email])
  #   if @user
  #   if @user.verification_code == params[:verification_code]
  #     @user.update!(is_email_verified: true)
  #       flash.now[:notice] = "Email verified successfully. Thanks for the verification."
  #         UserMailer.welcome_email(@user).deliver_now
  #     render ('user_mailer/verifciation_redirect_page')
  #   else
  #     flash.now[:alert_danger] = "Verification code didn't match."
  #     render :verifciation_redirect_page
  #   end
  # else
  #   flash.now[:alert_danger] = "We couldn't find user associated with this email."
  #   render ('user_mailer/verifciation_redirect_page')
  # end
  # end

  api :POST, '/api/v1/auth/update-password', 'To update password'
  param :email, String, :desc => "Email", :required => true
  param :password, String, :desc => "Password", :required => true

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
