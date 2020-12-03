class Dashboard::Api::V1::UsersController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request, except: ['create']
  before_action :checkout_logout, except: :create
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper


     resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/users', 'Get all users'
  # GET /users
  def index

    app = User.app_users.page(params[:page]).per(20).map  { |user| get_user_object(user) }
    business = User.web_users.page(params[:page]).per(20).map { |user| get_business_object(user) }

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
  def show
    @user = User.find(params[:id])

    profile = {
        "user_id" => @user.id,
        "email_addrress" =>  @user.email,
        "avatar" => @user.avatar,
        "mobile_number" =>  @user.phone_number,
        "password" => @user.password,
        "business_name" => @user.business_profile.profile_name,
        "contact_name" =>  @user.business_profile.contact_name,
        "display_name" =>  @user.business_profile.display_name,
        "address" => @user.business_profile.address,
        "website" => @user.business_profile.website,
        "About" =>  @user.business_profile.about,
        "youtube" =>  @user.business_profile.youtube,
        "instagram" =>  @user.business_profile.instagram,
        "twitter" =>  @user.business_profile.twitter,
        "linkedin" =>  @user.business_profile.linkedin,
        "facebook" => @user.business_profile.facebook

    }

    render json: {
     code: 200,
     success: true,
     message: '',
     data: {
       event: profile
     }
   }
    # render json: @user, status: :ok
  end


  api :POST, 'dashboard/api/v1/users', 'Create new user'
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

  def create
    required_fields = ['profile_name', 'contact_name','address', 'display_name', 'phone_number', 'email', 'password','website','is_charity', 'about']
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
      @user.web_user = true
      @user.password = params[:password]
      @user.verification_code = generate_code
      @user.stripe_state = generate_code

      if !params[:charity_number].blank?
        charity_number = params[:charity_number]
      else
        charity_number = ''
      end

      user_and_profile_errors = []


      if @user.save
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

       setting_name_values.each do |name|
         new_setting = Setting.create!(user: @user, name: name, is_on: true)
       end #each

        #create role
        assignment = @user.assignments.create!(role_id: params[:type])
      else
        @user.errors.full_messages.map { |m| user_and_profile_errors.push(m) }

      end

      @business = BusinessProfile.new

        @business.user = @user

        @business.profile_name = params[:profile_name]
        @business.contact_name = params[:contact_name]
        @business.display_name = params[:display_name]
        @business.address = params[:address]
        @business.website = params[:website]
        @business.about = params[:about]
        @business.vat_number = params[:vat_number]
        @business.youtube = params[:youtube]
        @business.instagram = params[:instagram]
        @business.twitter = params[:twitter]
        @business.linkedin = params[:linkedin]
        @business.facebook = params[:facebook]


       if @business.save
        "do nothing"
      else
          @business.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
      end
       #Also save default setting


    if user_and_profile_errors.blank?
      profile = {
        "user_id" => @user.id,
        "email_addrress" =>  @user.email,
        "avatar" => @user.avatar,
        "mobile_number" =>  @user.phone_number,
        "password" => @user.password,
        "business_name" => @business.profile_name,
        "contact_name" =>  @business.contact_name,
        "display_name" =>  @business.display_name,
        "address" => @business.address,
        "website" => @business.website,
        "About" =>  @business.about,
        "youtube" =>  @business.youtube,
        "instagram" =>  @business.instagram,
        "twitter" =>  @business.twitter,
        "linkedin" =>  @business.linkedin,
        "facebook" => @business.facebook,
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

  def update
   required_fields = ['profile_name', 'contact_name','address', 'display_name', 'phone_number', 'email', 'password','website','is_charity', 'about']
    errors = []
    required_fields.each do |field|
      if params[field.to_sym].blank?
        errors.push(field + ' is required.')
      end
    end

   if errors.blank?
    registered  = false
    @user = User.find(params[:id])
    if params[:avatar].blank?
     @user.remote_avatar_url = get_dummy_avatar
    else
      @user.avatar = params[:avatar]
    end
      @user.phone_number = params[:phone_number]
      @user.email = params[:email]
      @user.web_user = true
      @user.password = params[:password]
      @user.verification_code = generate_code
      @user.stripe_state = generate_code

      if !params[:charity_number].blank?
        charity_number = params[:charity_number]
      else
        charity_number = ''
      end

      user_and_profile_errors = []


      if @user.save
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

       setting_name_values.each do |name|
         new_setting = Setting.create!(user: @user, name: name, is_on: true)
       end #each

        #create role
        assignment = @user.assignments.create!(role_id: params[:type])
      else
        @user.errors.full_messages.map { |m| user_and_profile_errors.push(m) }

      end

      @business = BusinessProfile.find(params[:id])

        @business.user = @user

        @business.profile_name = params[:profile_name]
        @business.contact_name = params[:contact_name]
        @business.display_name = params[:display_name]
        @business.address = params[:address]
        @business.website = params[:website]
        @business.about = params[:about]
        @business.vat_number = params[:vat_number]
        @business.youtube = params[:youtube]
        @business.instagram = params[:instagram]
        @business.twitter = params[:twitter]
        @business.linkedin = params[:linkedin]
        @business.facebook = params[:facebook]


       if @business.save
        "do nothing"
      else
          @business.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
      end
       #Also save default setting


    if user_and_profile_errors.blank?
      profile = {
        "user_id" => @user.id,
        "email_addrress" =>  @user.email,
        "avatar" => @user.avatar,
        "mobile_number" =>  @user.phone_number,
        "password" => @user.password,
        "business_name" => @business.profile_name,
        "contact_name" =>  @business.contact_name,
        "display_name" =>  @business.display_name,
        "address" => @business.address,
        "website" => @business.website,
        "About" =>  @business.about,
        "youtube" =>  @business.youtube,
        "instagram" =>  @business.instagram,
        "twitter" =>  @business.twitter,
        "linkedin" =>  @business.linkedin,
        "facebook" => @business.facebook

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
      message: user_and_profile_errors,
      data: nil
    }
  end
  end

end #class
