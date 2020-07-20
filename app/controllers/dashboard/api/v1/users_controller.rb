class Dashboard::Api::V1::UsersController < Api::V1::ApiMasterController
  before_action :authorize_request, except: :create
  before_action :checkout_logout, except: :create

  # GET /users
  def index
    @users = []
    User.all.each do |user|
      @users << {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        avatar: user.avatar,
        email: user.email,
        device_token: user.device_token,
        phone_number: user.phone_number,
        role: user.role,
        lat: user.lat,
        lng: user.lng,
        created_at: user.created_at,
        phone_verified: user.phone_verified
        
      }
    end
     resp = {
       code: 200,
       success: true,
       message: '',
       data: {
         users: @users
     }
    }
    render json: resp.to_json
  end

  # GET /users/{username}
  def show
    render json: @user, status: :ok
  end



  def create
    @user = User.new
    @user.first_name = params[:first_name]
    @user.last_name = params[:last_name]
    if params[:avatar].blank? 
     @user.remote_avatar_url = 'https://pickaface.net/gallery/avatar/45425654_200117_1657_v2hx2.png'
    else
      @user.avatar= params[:avatar]
    end
  
    @user.phone_number = params[:phone_number]
    @user.email = params[:email]
    @user.password = params[:password]
    @user.contact_name = params[:contact_name]
    @user.verification_code = generate_code
    if @user.save

       profile = BusinessProfile.create!(user: @user, address: params[:address], website: params[:website], about: params[:about], vat_number: params[:vat_number], charity_number: params[:charity_number])

       #Also save default setting
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']
       
       setting_name_values.each do |name|     
         new_setting = Setting.create!(user_id: @user.id, name: name, is_on: true)
       end #each

        @role = Assignment.new
        @role.role_id = 2#params[:type]
        @role.user_id = @user.id
        @role.save
      render json: { 
            code: 200,
            success: true,
            message: "Registered successfully.",
            data: {
              user: @user,
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
  end

  def send_verification_code
    if !params[:user_id].blank?
      user = User.find(params[:user_id])
      code = user.verification_code 
      if UserMailer.with(user: user).send_verification_code(user,code).deliver_now#UserMailer.deliver_now
     render json: {
       code: 200,
       success: true,
       message: 'Verification email successfully sent.',
       data: nil
     }    
    else
      render  json: {
        code: 400, 
        success: false,
        message: 'Verification email sending failed.',
        data: nil
      }
      false
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "user_id is required field.",
      data: nil
    }
  end
end

   
end #class
