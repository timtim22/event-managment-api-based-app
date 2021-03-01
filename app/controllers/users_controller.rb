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
      @user.phone_number = params[:phone_number]
      @user.email = params[:email]
      @user.password = params[:password]
      if params[:avatar].blank? 
         @user.remote_avatar_url = get_dummy_avatar 
       else
         @user.avatar= params[:avatar]
       end
       if !params[:charity_number].blank?
        charity_number = params[:charity_number]
       else
         charity_number = ''
        end
        
        website = ""
        if params[:website] != [/\Ahttp:\/\//] || [/\Ahttps:\/\//] || [/\Awww\/\//]
          website = "https://www.#{params[:website]}"
        elsif params[:website] != [/\Ahttp:\/\//] || [/\Ahttps:\/\//]
          website = "https://#{params[:website]}"
        elsif params[:website] != [/\Awww\/\//]
            website = "www.#{params[:website]}"
        else
          website = params[:website]
        end

        if @user.save    
          profile = BusinessProfile.create!(profile_name: params[:profile_name],stripe_state: generate_code, contact_name: params[:contact_name], user: @user, website: website, vat_number: params[:vat_number], charity_number: charity_number)

          #create role
           assignment = @user.assignments.create!(role_id: params[:type])

        # flash[:notice] = "Registered successfully, Please verify your phone."
         flash[:notice] = "Registered successfully, please login now."
         session[:phone_number] = @user.phone_number
         redirect_to new_admin_session_path
         UserMailer.welcome_email(@user).deliver_now
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


    def privacy_policy
      
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
