class Admin::UsersController < Admin::AdminMasterController
    before_action :getRoles, :only => [:new, :create, :edit]
    def index
        @users = User.all
    end 
    
    def new
        @user = User.new 
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
        @user = User.new(user_params)
        profile = Profile.new
        profile.user_id = @user.id
        profile.save
        if @user.save
          create_activity("registered", @user, "User")
         if(params[:type] == '3') #change later
          business_detail = BusinessDetail.new 
          business_detail.name = params[:business_name]
          business_detail.type = params[:business_type]
          business_detail.save
         end
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
      if @user.update(user_params)
      @role = @user.assignment
      @role.role_id = params[:type]
      @role.save
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
        create_activity("updated password", @user, "User")
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
        profile = user.profile
        profile.about = params[:about] 
        profile.gender = params[:gender]
        profile.stripe_account = params[:stripe_account]
        profile.add_social_media_links = params[:add_social_media_links]
        profile.facebook = params[:facebook]
        profile.twitter = params[:twitter]
        profile.snapchat = params[:snapchat]
        profile.instagram = params[:instagram]
      if profile.save
         create_activity("updated profile", user, "User")
         @user = User.find(current_user.id)
         @user.update(phone_number: params[:phone_number],dob: params[:dob])
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

    private

    def user_params
        params.permit(:first_name,:last_name,:avatar, :email, :password, :password_confirmation)
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
