class UsersController < ApplicationController
    before_action :getRoles, :only => [:new, :create]
   
    def index
        @users = User.all
    end 
    
    def new
        @user = User.new
    end

    def create
        @user = User.new
        @user.first_name = params[:first_name]
        @user.last_name =  params[:last_name]
        @user.email = params[:email]
        @user.phone_number = params[:phone_number]
        @user.dob = params[:dob]
        @user.gender = params[:gender]
        @user.stripe_state = generate_code
        @user.password = params[:password]
        @user.remote_avatar_url = 'https://pickaface.net/gallery/avatar/45425654_200117_1657_v2hx2.png'  
        if @user.save
            profile = Profile.new
            profile.user_id = @user.id
            profile.save
            @role = Assignment.new()
            @role.role_id = params[:type]
            @role.user_id = @user.id
            @role.save
           if(params[:type] == '3')
              business_detail = BusinessDetail.new 
              business_detail.name = params[:business_name]
              business_detail.type = params[:business_type]
              business_detail.save
            end
        # flash[:notice] = "Registered successfully, Please verify your phone."
         flash[:notice] = "Registered successfully, please login now."
         session[:phone_number] = @user.phone_number
         redirect_to new_admin_session_path
        else
         render :new
        end
    end

    def verify_phone_page
      render :phone_verification
    end

    def verify_phone
      phone = params[:phone_number]
      @user = User.find_by(phone_number: phone)
      @user.phone_verified = true
      @user.save
      render json: {
        success: true,
        message: 'Phone number verified successfully.'
      }
    end

    private

    def user_params
        params.permit(:first_name,:last_name, :email, :phone_number, :dob, :password, :password_confirmation,:app_user)
    end

    def assignment_params
        params.permit(:type)
    end

    def getRoles
     @roles = Role.all
    end
end
