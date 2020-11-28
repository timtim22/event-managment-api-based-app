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
    render json: @user, status: :ok
  end


  api :POST, 'dashboard/api/v1/users', 'Create new user'
  param :type, :number, :desc => "Role ID (1,2,3)", :required => true
  param :profile, String, :desc => "Profile Name", :required => true
  param :contact_name, String, :desc => "Contact Name", :required => true
  param :address, String, :desc => "Address", :required => true
  param :vat_number, :number, :desc => "Vat number", :required => true
  param :website, String, :desc => "website", :required => true
  param :is_charity, ['True', 'False'], :desc => "User ID", :required => true
  param :avatar, String, :desc => "Avatar"
  #param :phone_number, String
  param :email, String, :desc => "Email"
  param :web_user, ['True', 'False']
  #param :password, String, :desc => "Password"


  def create
    required_fields = ['type', 'profile_name', 'contact_name','address', 'vat_number','website','is_charity']
    errors = []
    required_fields.each do |field|
      if params[field.to_sym].blank?
        errors.push(field + ' is required.')
      end
    end

   if errors.blank?
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

    if @user.save &&  BusinessProfile.create!(profile_name: params[:profile_name], contact_name: params[:contact_name], user: @user, address: params[:address], website: params[:website], about: params[:about], vat_number: params[:vat_number], charity_number: charity_number, is_charity: params[:is_charity])


       #Also save default setting
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

       setting_name_values.each do |name|
         new_setting = Setting.create!(user_id: @user.id, name: name, is_on: true)
       end #each

        #create role
        assignment = @user.assignments.create!(role_id: params[:type])

      render json: {
            code: 200,
            success: true,
            message: "Registered successfully.",
            data: {
              user: get_business_object(@user),
              token: encode(user_id: @user.id),
            }
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
      success:false,
      message: errors,
      data: nil
    }
  end
  end

  api :POST, 'dashboard/api/v1/users', 'Create new user'
  param :id, :number, :desc => "ID of the user", :required => true
  param :type, :number, :desc => "Role ID (1,2,3)", :required => true
  param :profile, String, :desc => "Profile Name", :required => true
  param :contact_name, String, :desc => "Contact Name", :required => true
  param :address, String, :desc => "Address", :required => true
  param :vat_number, :number, :desc => "Vat number", :required => true
  param :website, String, :desc => "website", :required => true
  param :is_charity, ['True', 'False'], :desc => "User ID", :required => true
  param :avatar, String, :desc => "Avatar"
  #param :phone_number, String
  param :email, String, :desc => "Email"
  param :web_user, ['True', 'False']
  #param :password, String, :desc => "Password"

  def update
   if !params[:id].blank?
    @user = User.find(params[:id])
    if params[:avatar].blank?
     @user.remote_avatar_url = get_dummy_avatar
    else
      @user.avatar= params[:avatar]
    end

    @user.phone_number = params[:phone_number]

    if  profile = @user.business_profile.update!(profile_name: params[:profile_name], contact_name: params[:contact_name], user: @user, address: params[:address], website: params[:website], about: params[:about], vat_number: params[:vat_number], charity_number: params[:charity_number], is_charity: params[:is_charity]) &&   @user.save



       #Also save default setting
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

       setting_name_values.each do |name|
         new_setting = Setting.create!(user_id: @user.id, name: name, is_on: true)
       end #each



      render json: {
            code: 200,
            success: true,
            message: "Profile updated successfully.",
            data: {
              user: get_business_object(@user)
            }
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
    render json:  {
      code: 400,
      success: false,
      message: 'id is required.',
      data: nil
    }
  end
  end

  api :GET, 'dashboard/api/v1/get-app-users', 'Get all app users'

  def get_app_users

  @users = User.app_users.map {|user| get_user_object(user) }

    render json: {
      code: 200,
      success: true,
      data: {
        users: @users
      }
    }
  end

  api :POST, 'dashboard/api/v1/get-user', 'Get specific user'
  param :id, :number, :desc => "ID of the user", :required => true

  def get_user
    if !params[:user_id].blank?
       user = User.find(params[:user_id])
     if user.web_user ==  true
       business = {}
        business['id'] = user.id,
        business['profile_name'] = user.business_profile.profile_name,
        business['avatar'] = user.avatar,
        business['email'] = user.email,
        business['contact_name'] = user.business_profile.contact_name,
        business['address'] = user.business_profile.address,
        business['vat_number'] = user.business_profile.vat_number,
        business['charity_number'] = user.business_profile.charity_number,
        business['website']  = user.business_profile.website,
        business['about'] = user.business_profile.about,
        business['phone_number'] = user.phone_number,
        business['roles'] = user.roles

      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          profile: business
        }
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'This user is not a business user',
        data: nil
      }
    end

    else
      render json: {
       code: 400,
       success: false,
       message: 'user_id is required field.',
       data: nil
      }
    end
  end

end #class
