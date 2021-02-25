class Dashboard::Api::V1::Users::UsersController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request, except: ['create_user']
  before_action :checkout_logout, except: :create_user
  require 'action_view'
  require 'action_view/helpers'
  require 'json'
  include ActionView::Helpers::DateHelper


     resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/show-all-users', 'Get all users'
  # GET /users
  # def index
  def show_all_users
    app = Assignment.where(role_id: 5).map {|assignment| assignment.user }
    business = Assignment.where(role_id: 2).map {|assignment| assignment.user }

    render json: {
      code: 200,
      success: true,
      data: {
        users: {
          "businesses" => business,
          "app_users" => app
        }
      }
    }
  end

  # GET /users/{username}
  def get_user
    if !params[:user_id].blank?
          @user = User.find(params[:user_id])
          profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "password" => @user.password,
              "followers_count" => @user.followers.size,
              "address" => jsonify_location(@user.location),
              "is_subscribed" => @user.is_subscribed,
              "device_token" => @user.device_token,
              "about" => @user.about,
              "profile_name" => @user.business_profile.profile_name,
              "contact_name" => @user.business_profile.contact_name,
              "display_name" => @user.business_profile.display_name,
              "website" => @user.business_profile.website,
              "vat_number" => @user.business_profile.vat_number,
              "charity_number" => @user.business_profile.charity_number,
              "is_charity" => @user.business_profile.is_charity,
              "youtube" => @user.social_media.youtube,
              "instagram" => @user.social_media.instagram,
              "linkedin" => @user.social_media.linkedin,
              "facebook" => @user.social_media.facebook,
              "twitter" => @user.social_media.twitter
              }

          render json: {
           code: 200,
           success: true,
           message: '',
           data: {
             event: profile
              }
            }
    else
          render json: {
           code: 200,
           success: true,
           message: 'user_id is required',
           data: nil
         }

    end
    # render json: @user, status: :ok
  end


  api :POST, 'dashboard/api/v1/users/create-user', 'Create new user'
  # param :type, :number, :desc => "Role ID (1,2,3)", :required => true
  # param :profile_name, String, :desc => "Profile Name", :required => true
  # param :contact_name, String, :desc => "Contact Name", :required => true
  # param :address, String, :desc => "Address", :required => true
  # param :vat_number, :number, :desc => "Vat number", :required => true
  # param :website, String, :desc => "website", :required => true
  # param :is_charity, ['True', 'False'], :desc => "User ID", :required => true
  # param :avatar, String, :desc => "Avatar"
  # param :phone_number, String
  # param :email, String, :desc => "Email"
  # param :web_user, ['True', 'False']
  # param :password, String, :desc => "Password"

  def create_user
    required_fields = ['profile_name', 'contact_name','location', 'display_name', 'phone_number', 'email', 'role_id', 'password','is_charity', 'about']
    errors = []
    required_fields.each do |field|
      if params[field.to_sym].blank?
        errors.push(field + ' is required.')
      end
    end

   if errors.blank?
    registered  = false
    @user = User.new
    if params[:avatar].blank?
     @user.remote_avatar_url = get_dummy_avatar
    else
      @user.avatar = params[:avatar]
    end
      @user.phone_number = params[:phone_number]
      @user.email = params[:email]
      @user.password = params[:password]
      @user.location = params[:location]
      @user.is_subscribed = params[:is_subscribed]
      @user.about = params[:about]
      @user.mobile_user = false
      @user.uuid = generate_uuid

      user_and_profile_errors = []


      if @user.save
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

       setting_name_values.each do |name|
         new_setting = Setting.create!(user: @user, name: name, is_on: true)
       end #each

        #create role
        assignment = @user.assignments.create!(role_id: params[:role_id])
      else
        @user.errors.full_messages.map { |m| user_and_profile_errors.push(m) }

      end

      @business = BusinessProfile.new

        @business.user = @user

        @business.profile_name = params[:profile_name]
        @business.contact_name = params[:contact_name]
        @business.display_name = params[:display_name]
        @business.website = params[:website]
        @business.vat_number = params[:vat_number]
        @business.charity_number = params[:charity_number]
        @business.is_charity = params[:is_charity]
        @business.stripe_state = generate_code


        if @business.save
          "do nothing"
        else
            @business.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
        end
       #Also save default setting

        @social = SocialMedia.new

        @social.user = @user

        @social.youtube = params[:youtube]
        @social.instagram = params[:instagram]
        @social.twitter = params[:twitter]
        @social.facebook = params[:facebook]
        @social.snapchat = params[:snapchat]
        @social.linkedin = params[:linkedin]

        if @social.save
          "do nothing"
        else
            @social.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
        end

        assignment = @user.assignments.create!(role_id: params[:role_id])


      if user_and_profile_errors.blank?


      profile = {
        "user_id" => @user.id,
        "email" =>  @user.email,
        "avatar" => @user.avatar,
        "phone_number" =>  @user.phone_number,
        "is_subscribed" => @user.is_subscribed,
        "device_token" => @user.device_token,
        "location" => jsonify_location(@user.location),
        "about" => @user.about,
        "profile_name" => @business.profile_name,
        "contact_name" =>  @business.contact_name,
        "display_name" =>  @business.display_name,
        "website" => @business.website,
        "vat_number" =>  @business.vat_number,
        "charity_number" =>  @business.charity_number,
        "is_charity" =>  @business.is_charity,
        "youtube" =>  @social.youtube,
        "instagram" =>  @social.instagram,
        "twitter" =>  @social.twitter,
        "linkedin" =>  @social.linkedin,
        "facebook" => @social.facebook,
        "snapchat" => @social.snapchat,
        "token" =>   encode(user_id: @user.id)
      }

      render json: {
        code: 200,
        success: true,
        message: "Registered successfully",
        data: {
          profile: profile
        }
      }
      else
        render json: {
        code: 400,
        success: false,
        message: user_and_profile_errors,
        data: nil
      }
    end

  else

    render json: {
      code: 400,
      success:false,
      message: errors,
      data: nil
    }
  end
  end

  api :POST, 'dashboard/api/v1/users', 'Create new user'
  # param :id, :number, :desc => "ID of the user", :required => true
  # param :type, :number, :desc => "Role ID (1,2,3)", :required => true
  # param :profile, String, :desc => "Profile Name", :required => true
  # param :contact_name, String, :desc => "Contact Name", :required => true
  # param :address, String, :desc => "Address", :required => true
  # param :vat_number, :number, :desc => "Vat number", :required => true
  # param :website, String, :desc => "website", :required => true
  # param :is_charity, ['True', 'False'], :desc => "User ID", :required => true
  # param :avatar, String, :desc => "Avatar"
  # param :phone_number, String
  # param :email, String, :desc => "Email"
  # param :web_user, ['True', 'False']
  #param :password, String, :desc => "Password"

  def update_user
    if !params[:user_id].blank?
         required_fields = ['profile_name', 'contact_name','location', 'display_name', 'phone_number', 'email', 'password','is_charity', 'about']
          errors = []
          required_fields.each do |field|
            if params[field.to_sym].blank?
              errors.push(field + ' is required.')
            end
          end

    if errors.blank?
          registered  = false
          @user = User.find(params[:user_id])
          if params[:avatar].blank?
           @user.remote_avatar_url = get_dummy_avatar
          else
            @user.avatar = params[:avatar]
          end
            @user.phone_number = params[:phone_number]
            @user.email = params[:email]
            @user.password = params[:password]
            @user.location = params[:location]
            @user.is_subscribed = params[:is_subscribed]
            @user.about = params[:about]
            @user.mobile_user = false

            user_and_profile_errors = []


            if @user.save
             setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

               setting_name_values.each do |name|
                 new_setting = Setting.create!(user: @user, name: name, is_on: true)
               end #each

              #create role
              assignment = @user.assignments.create!(role_id: params[:role_id])
            else
              @user.errors.full_messages.map { |m| user_and_profile_errors.push(m) }

            end
       
            @business = @user.business_profile

              @business.profile_name = params[:profile_name]
              @business.contact_name = params[:contact_name]
              @business.display_name = params[:display_name]
              @business.website = params[:website]
              @business.vat_number = params[:vat_number]
              @business.charity_number = params[:charity_number]
              @business.is_charity = params[:is_charity]
              @business.stripe_state = generate_code


             if @business.save
              "do nothing"
             else
                  @business.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
             end
               #Also save default setting

              @social = @user.social_media

              @social.youtube = params[:youtube]
              @social.instagram = params[:instagram]
              @social.twitter = params[:twitter]
              @social.facebook = params[:facebook]
              @social.snapchat = params[:snapchat]
              @social.linkedin = params[:linkedin]

              if @social.save
                "do nothing"
              else
                  @social.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
              end


          if user_and_profile_errors.blank?
            profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "is_subscribed" => @user.is_subscribed,
              "device_token" => @user.device_token,
              "location" => jsonify_location(@user.location),
              "about" => @user.about,
              "profile_name" => @business.profile_name,
              "contact_name" =>  @business.contact_name,
              "display_name" =>  @business.display_name,
              "website" => @business.website,
              "vat_number" =>  @business.vat_number,
              "charity_number" =>  @business.charity_number,
              "is_charity" =>  @business.is_charity,
              "youtube" =>  @social.youtube,
              "instagram" =>  @social.instagram,
              "twitter" =>  @social.twitter,
              "linkedin" =>  @social.linkedin,
              "facebook" => @social.facebook,
              "snapchat" => @social.snapchat,
              "token" =>   encode(user_id: @user.id)
            }

            render json: {
              code: 200,
              success: true,
              message: "User successfully updated",
              data: {
                profile: profile
              }
            }
            else
              render json: {
              code: 400,
              success: false,
              message: user_and_profile_errors,
              data: nil
            }
          end

        else

          render json: {
            code: 400,
            success:false,
            message: errors,
            data: nil
          }
        end
      
  else
          render json: {
            code: 400,
            success:false,
            message: "user_id is required",
            data: nil
          }

  end
end
end #class
