class Admin::UsersController < Admin::AdminMasterController
    before_action :getRoles, :only => [:new, :create, :edit]
    def index
        @users = User.order(id: 'DESC')
    end 
    
    def new
        @user = User.new 
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
        @user = User.new()
       
        if @user.save
           
          profile = BusinessProfile.create!(name: params[:profile_name], contact_name: params[:contact_name], address: params[:address], about: params[:about], website: params[:website], vat_number: params[:vat_number], charity_number: params[:charity_number])

          @role = Assignment.new
          @role.role_id = params[:type]
          @role.user_id = @user.id
          @role.save
         flash[:notice] = "User created successfully"
         redirect_to admin_users_path
        else
         render :new
        end
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params) &&  @user.assignments.first.update!(role_id: params[:type])
    
       flash[:notice] = "User Updated successfully."
       redirect_to admin_users_path
      else
        flash[:alert_danger] = "User couldn't be updated."
       redirect_to admin_users_path
      end
    end

    def destroy
      @user = User.find(params[:id])
      if @user.destroy
        flash[:notice] = "User deleted successfully."
        redirect_to admin_users_path
      else
        flash[:alert_danger] = "User deletion failed."
        redirect_to admin_users_path
      end
    end

    def get_profile
        render :profile
    end

    def update_password
      @user = current_user()
       old_password = params[:old_password]
       new_password = params[:new_password]
     if(!@user.authenticate(old_password)) 
        render json: {
          'success':false,
           message: "Your old password is incorrect."
        }
     else
      @user.password = new_password
      if @user.save()
        create_activity("updated password", @user, "User", '', '', 'post')
        render json: {
          success: true,
          message: "Password updated successfully."
        }
      else
        render json: {
          success: false,
          message: "Password update failed."
        }
      end
     end
    end

    
    def update_avatar
      @user = current_user()      
      if @user.update(profile_update_params)
        create_activity("updated avatar", @user, "User", admin_users_path(@user), '', 'patch')
        flash[:notice] = "Profile updated successfully."
        redirect_to admin_user_get_profile_path
      else
        flash[:alert_danger] = "Profile update was not successful."
        redirect_to admin_user_get_profile_path
      end
    end

    def update_info
        user = current_user()
        profile = user.business_profile
        profile.profile_name = params[:profile_name]
        profile.contact_name = params[:contact_name]  
        profile.about = params[:about] 
        profile.vat_number = params[:vat_number]
        profile.charity_number = params[:charity_number]
        profile.website = params[:website]
        profile.address = params[:address]
        profile.facebook = params[:facebook]
        profile.twitter = params[:twitter]
        profile.linkedin = params[:linkedin]
        profile.instagram = params[:instagram]
      if profile.save
        current_user.update!(phone_number: params[:phone_number])
        create_activity("Updated profile.", profile, "BusinessProfile", '', 'profile', 'post')
        render json: {
          success: true,
          message: "successfully updated."
        }
      else
        render json: {
          success: false,
          message: "Info update failed."
        }
      end
    end

    def view_activity
      @activity_logs = current_user.activity_logs.order(:created_at => "DESC").page(params[:page])
      render :my_activity
     end

     def send_email_page
       
     end

     def send_reset_email
      if !params[:email].blank?
         @user = User.find_by(email: params[:email])
        if @user
          @token = generate_code

          @user.password_resets.create!(token: @token)

          @url = "#{ENV['BASE_URL']}/admin/reset-password-page?email=#{@user.email}&&token=#{@token}"
          if PasswordResetMailer.with(user: @user).password_reset_email(@user,@url).deliver_now#UserMailer.deliver_now
            render json: {
            code:200,
            success: true,
            message: "Email successfully sent. Please check your inbox to follow the instructions.",
            data: nil
          } 
        else
          render json: {
            code:400,
            success: false,
            message: "Email was not sent, Please try again.",
            data: nil
          }
        end
        else
          render json: {
            code:400,
            success: false,
            message: "The email is not registered with us.",
            data: nil
          }
        end
        else
          render json: {
            code:400,
            success: false,
            message: "Please provide and email",
            data: nil
          }
        end
       end
    
       def reset_password_page
        @email = params[:email]
        @token = params[:token]
        @user = User.find_by(email: @email)
        @reset_token = @user.password_resets.where(token: @token)
        if !@user.blank? && !@reset_token.blank?
          @can_reset = true
        else
          @cant_reset = false
          flash.now[:alert_danger] = "Either the link is expired or link is incorrect."
        end
       end

       def reset_password
        if !params[:new_password].blank?
          if params[:new_password] ==  params[:confirm_password]
            @user = User.find_by(email: params[:email])
            @user.password = params[:new_password]
          if @user.save()
            render json: {
              code: 200,
              success: true,
              message: "Password updated successfully.",
              data: nil
            }
          else
            render json: {
              code: 400,
              success: false,
              message: @user.errors.full_messages,
              data: nil
            }
          end
          else
            render json: {
              code: 400,
              success: false,
              message: "Password confirmation failed.",
             
              data: nil
            }

          end
        else
          render json: {
            code: 400,
            success: false,
            message: "Password can't be blank.",
            p: params[:new_password],
            data: nil
          }
        end
      
      end
    


     ####################################### Privae ########################################3

    private

    def user_params
        params.permit(:profile_name,:contact_name,:avatar, :email, :password, :password_confirmation)
    end

    def profile_update_params
     params.permit(:avatar)
    end

    def profile_params
      params.permit(:dob,:mobile,:about,:gender,:stripe_account, :add_social_media_links)
    end

    def getRoles
       @roles = Role.all
   end
end
