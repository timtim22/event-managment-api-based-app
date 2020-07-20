class Api::V1::UsersController < Api::V1::ApiMasterController
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
        phone_verified: user.phone_verified,
        is_ambassador: user.is_ambassador,
        is_my_friend: is_my_friend?(user),
        is_my_following: if user.role.id ==  2 then is_my_following?(user) else false end,
        mutual_friends_count: user.friends.size,
        is_request_sent: request_status(request_user, user)
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

  # POST /users
  def create
    if params[:contact_name].blank?
      errors.add(:contact_name, " must exist.")
      false
    end
    @user = User.new
    @user.first_name = params[:first_name]
    @user.last_name = params[:last_name]
    if params[:avatar].blank? 
    @user.remote_avatar_url = 'https://pickaface.net/gallery/avatar/45425654_200117_1657_v2hx2.png'
    else
      @user.avatar= params[:avatar]
    end
    @user.dob = params[:dob]
    @user.app_user = params[:app_user]
    @user.phone_number = params[:phone_number]
    @user.email = params[:email]
    @user.image_link = params[:image_link]
    @user.device_token = params[:device_token]
    @user.gender = params[:gender]
    @user.lat = params[:lat]
    @user.lng = params[:lng]
    @user.is_subscribed = params[:is_subscribed]
    @user.verification_code = generate_code
    if @user.save
       profile = Profile.new
       profile.user_id = @user.id
       profile.save

       #Also save default setting
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']
       
       setting_name_values.each do |name|     
         new_setting = Setting.create!(user_id: @user.id, name: name, is_on: true)
       end #each
     
       if params[:is_subscribed] ==  'true'
       #send verification email
        email_sent =  send_verification_email(@user)
       else
        email_sent = "No email was sent"
       end      

       #applicable only if user is invited
       if !params[:inviter_phone].blank?
         inviter = User.where(phone_number: params[:inviter_phone]).first
         if inviter
          invitee = @user
          auto_friendship(inviter, invitee)
         end
       end
        @role = Assignment.new
        @role.role_id = params[:type]
        @role.user_id = @user.id
        @role.save
      render json: { 
            code: 200,
            success: true,
            message: "Registered successfully.",
            data: {
              user: @user,
              token: encode(user_id: @user.id),
              email_sent: email_sent,
              params: params
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

  # PUT /users/{username}
  def update
    unless @user.update(user_params)
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /users/{username}
  def destroy
    @user.destroy
  end

  def update_avatar
    @user = current_user()      
    if @user.update(profile_update_params)
      create_activity("updated profile picture.", @user, "User")
      render json: {
        success: true,
        message:  "Profile picture updated successfully."
      }
    else
      render json: {
        success: false,
        message:  @user.errors.full_messages
      }
    end
  end

  def update_profile
    params.permit(:avatar)
    user = request_user
    profile = user.profile
    user.first_name = params[:first_name]
    user.last_name = params[:last_name]
    user.avatar = params[:avatar] 
    user.gender = params[:gender]
    profile.about = params[:about]
    profile.add_social_media_links = params[:add_social_media_links]
    profile.facebook = params[:facebook]
    profile.twitter = params[:twitter]
    profile.snapchat = params[:snapchat]
    profile.linkedin = params[:linkedin]
    profile.youtube = params[:youtube]
    profile.instagram = params[:instagram]
    user.avatar = params[:avatar]
    user.dob = params[:dob]
    user.phone_number = params[:phone_number]
  if profile.save &&  user.update!(user_params)
   # create_activity("updated profile.", profile, "Profile")
    render json: {
      code: 200,
      success: true,
      message: "successfully updated.",
      data: {
        user: user,
        profile: profile
      }
    }
  else
    render json: {
      code: 400,
      success: false,
      message: { profile_errors: profile.errors.full_messages, user_errors: user.errors.full_messages },
      data: nil
    }
  end
end

  def get_profile
    user = request_user
      profile = {}
      attending = []
      competitions = []
      user.events_to_attend.each do |event|
      attending << {
        "event_id" => event.id,
        "name" => event.name,
        "start_date" => event.start_date,
        "end_date" => event.end_date,
        "start_time" => event.start_time,
        "end_time" => event.end_time,
        "location" => event.location,
        "lat" => event.lat,
        "lng" => event.lng,
        "event_type" => event.event_type,
        "image" => event.image,
        "eventbrite_image" => event.eventbrite_image,
        "price_type" => event.price_type,
        "price" => event.price,
        "additional_media" => event.event_attachments,
        "created_at" => event.created_at,
        "updated_at" => event.updated_at,
        "host" => event.host,
        "host_image" => event.user.avatar.url,
        "interest_count" => event.interested_interest_levels.size,
        "going_count" => event.going_interest_levels.size,
        "demographics" => get_demographics(event)
      }
    end
    user.competitions_to_attend.each do |competition|
    competitions << {
      id: competition.id,
      title: competition.title,
      description: competition.description,
      location: competition.location,
      start_date: competition.start_date,
      end_date: competition.end_date,
      start_time: competition.start_time,
      end_time: competition.end_time,
      price: competition.price,
      lat: competition.lat,
      lng: competition.lng,
      image: competition.image.url,
      friends_participants_count: competition.registrations.map {|reg| if(request_user.friends.include? reg.user) then reg.user end }.size,
      creator_name: competition.user.first_name + " " + competition.user.last_name,
      creator_image: competition.user.avatar.url,
      validity: competition.validity.strftime(get_time_format)
      }
      end
      profile['first_name'] = user.first_name 
      profile['last_name'] = user.last_name
      profile['avatar'] = user.avatar.url
      profile['lat'] = user.lat
      profile['lng'] = user.lng
      profile['about'] = user.profile.about
      profile['dob'] = user.dob
      profile['role'] = user.role.name
      profile['role_id'] = user.role.id
      profile['gender'] = user.gender
      profile['mobile'] = user.phone_number
      profile['email'] = user.email
      profile['facebook'] = user.profile.facebook
      profile['twitter'] = user.profile.twitter
      profile['snapchat'] = user.profile.snapchat
      profile['instagram'] = user.profile.instagram
      profile['linkedin'] = user.profile.linkedin
      profile['youtube'] = user.profile.youtube
      profile['friends_count'] = user.friends.size
      profile['follows_count'] = user.followings.size
      profile['followers_count'] = user.followers.size
      # if user.is_ambassador to be added later
      #   profile['passes'] = 'to be added after ambassador shcema'
      # end
      profile['competitions'] = competitions
      profile['attending'] = attending
      profile['activities'] = user.activity_logs
      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          profile: profile
        } 
      }  
end

 def get_others_profile
  if !params[:user_id].blank?
  user = User.find(params[:user_id])
  profile = {}
  attending = []
  competitions = []
  user.events_to_attend.each do |event|
  attending << {
    "event_id" => event.id,
    "name" => event.name,
    "start_date" => event.start_date,
    "end_date" => event.end_date,
    "start_time" => event.start_time,
    "end_time" => event.end_time,
    "location" => event.location,
    "lat" => event.lat,
    "lng" => event.lng,
    "event_type" => event.event_type,
    "image" => event.image,
    "eventbrite_image" => event.eventbrite_image,
    "price_type" => event.price_type,
    "price" => event.price,
    "additional_media" => event.event_attachments,
    "created_at" => event.created_at,
    "updated_at" => event.updated_at,
    "host" => event.host,
    "host_image" => event.user.avatar.url,
    'interest_count' => event.interested_interest_levels.size,
    'going_count' => event.going_interest_levels.size,
    'demographics' => get_demographics(event)
  }
end
  user.competitions_to_attend.each do |competition|
    competitions << {
    id: competition.id,
    title: competition.title,
    description: competition.description,
    location: competition.location,
    start_date: competition.start_date,
    end_date: competition.end_date,
    start_time: competition.start_time,
    end_time: competition.end_time,
    price: competition.price,
    lat: competition.lat,
    lng: competition.lng,
    image: competition.image.url,
    friends_participants_count: competition.registrations.map {|reg| if(request_user.friends.include? reg.user) then reg.user end }.size,
    creator_name: competition.user.first_name + " " + competition.user.last_name,
    creator_image: competition.user.avatar.url,
    validity: competition.validity.strftime(get_time_format)
    }
    end
  profile['user_id'] = user.id
  profile['first_name'] = user.first_name 
  profile['last_name'] = user.last_name
  profile['avatar'] = user.avatar.url
  profile['about'] = user.profile.about
  profile['dob'] = user.dob
  profile['role'] = user.role.name
  profile['role_id'] = user.role.id
  profile['gender'] = user.gender
  profile['mobile'] = user.phone_number
  profile['email'] = user.email
  profile['lat'] = user.lat
  profile['lng'] = user.lng
  profile['facebook'] = user.profile.facebook
  profile['twitter'] = user.profile.twitter
  profile['snapchat'] = user.profile.snapchat
  profile['instagram'] = user.profile.instagram
  profile['linkedin'] = user.profile.linkedin
  profile['youtube'] = user.profile.youtube
  profile['friends_count'] = user.friends.size
  profile['follows_count'] = user.followings.size
  profile['followers_count'] = user.followers.size

  # if user.is_ambassador to be added later
  #   profile['passes'] = 'to be added after ambassador shcema'
  # end
  profile['competitions'] = competitions
  profile['attending'] = attending
  profile['activities'] = user.activity_logs
  render json: {
    code: 200,
    success: true,
    message: '',
    data: {
      profile: profile,
      user: request_user
    } 
  }
else
  render json: {
    code: 400,
    success: false,
    message: 'user_id is required.',
    data: nil
  }
end  
 end

 #own profile
 def get_business_profile
      user = request_user
      profile = {}
      offers = {}
      offers['special_offers'] = user.special_offers
      offers['passes'] = user.passes
      profile['first_name'] = user.first_name 
      profile['last_name'] = user.last_name
      profile['avatar'] = user.avatar.url
      profile['about'] = user.profile.about
      profile['followers_count'] = user.followers.size
      profile['events_count'] = user.events.size
      profile['competitions_count'] = user.competitions.size
      profile['offers_count'] = user.passes.size + user.special_offers.size
      profile['competitions'] = user.competitions
      profile['events'] = user.events
      profile['offers'] = offers
      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          profile: profile
        } 
      }
 end

 def get_others_business_profile
      if !params[:user_id].blank?
      user = User.find(params[:user_id])
      profile = {}
      offers = {}
      location = {}
      location['lat'] = user.lat
      location['lng'] = user.lng
      events = []
      competitions = []
      user.events.each do |event|
        events << {
          "event_id" => event.id,
          "name" => event.name,
          "start_date" => event.start_date,
          "end_date" => event.end_date,
          "start_time" => event.start_time,
          "end_time" => event.end_time,
          "location" => event.location,
          "lat" => event.lat,
          "lng" => event.lng,
          "event_type" => event.event_type,
          "image" => event.image,
          "eventbrite_image" => event.eventbrite_image,
          "price_type" => event.price_type,
          "price" => event.price,
          "additional_media" => event.event_attachments,
          "created_at" => event.created_at,
          "updated_at" => event.updated_at,
          "host" => event.host,
          "host_image" => event.user.avatar.url,
          "interest_count" => event.interested_interest_levels.size,
          "going_count" => event.going_interest_levels.size,
          "demographics" => get_demographics(event)
        }
      end
      user.competitions.each do |competition|
        competitions << {
        id: competition.id,
        title: competition.title,
        description: competition.description,
        location: competition.location,
        start_date: competition.start_date,
        end_date: competition.end_date,
        start_time: competition.start_time,
        end_time: competition.end_time,
        price: competition.price,
        lat: competition.lat,
        lng: competition.lng,
        image: competition.image.url,
        friends_participants_count: competition.registrations.map {|reg| if(request_user.friends.include? reg.user) then reg.user end }.size,
        creator_name: competition.user.first_name + " " + competition.user.last_name,
        creator_image: competition.user.avatar.url,
        validity: competition.validity.strftime(get_time_format)
        }
        end
      offers['special_offers'] = user.special_offers
      offers['passes'] = user.passes
      profile['id'] = user.id
      profile['first_name'] = user.first_name 
      profile['last_name'] = user.last_name
      profile['avatar'] = user.avatar.url
      profile['about'] = user.profile.about
      profile['location'] = location
      profile['facebook'] = user.profile.facebook
      profile['twitter'] = user.profile.twitter
      profile['snapchat'] = user.profile.snapchat
      profile['instagram'] = user.profile.instagram
      profile['linkedin'] = user.profile.linkedin
      profile['youtube'] = user.profile.youtube
      profile['follows_count'] = user.followings.size
      profile['friends_count'] = user.friends.size
      profile['follows_count'] = user.followings.size
      profile['followers_count'] = user.followers.size
      profile['followers_count'] = user.followers.size
      profile['events_count'] = user.events.size
      profile['competitions_count'] = user.competitions.size
      profile['offers_count'] = user.passes.size + user.special_offers.size
      profile['competitions'] = competitions
      profile['events'] = events
      profile['offers'] = offers
      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          profile: profile,
          user: user
        } 
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'user_id is required.',
        data: nil
      }
    end
 end

  def get_activity_logs
    @activity_logs = request_user.activity_logs.order(:created_at => "DESC")
    render json: {
      code: 200,
      success: true,
      message: '',
      data:  {
        activity_logs: @activity_logs
      }
    }
  end

  def update_device_token
    if !params[:device_token].blank?
    if update = request_user.update!(device_token: params[:device_token])
      render json: {
        code: 200,
        success: true,
        message: 'Device token updated successfully.',
        data: nil
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
      message: "device_token is required field.",
      data: nil
    }
  end
  end

  def update_current_location
    if !params[:lat].blank? && !params[:lng].blank?
      user = request_user
      if user.update!(lat: params[:lat], lng: params[:lng])
        render json:  {
          code: 200,
          success: true,
          message: "Location successfully updated.",
          data: nil
        }
      else
        remder json:  {
          code: 400,
          success: false,
          message: user.errors.full_messages,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: 'lat and lng are required fields',
        data: nil
      }
    end
  end

  def update_setting
    if !params[:mute_notifications].blank?
         mute_notifications = params[:mute_notifications]
      if request_user.update!(mute_notifications: mute_notifications)
      render json: {
        code: 200,
        success: true,
        message: 'setting successfully updated.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'setting was not updated.',
        data: nil
      }
    end
    elsif  !params[:mute_chat].blank?
         mute_chat = params[:mute_chat]
      if request_user.update!(mute_chat: mute_chat)
      render json: {
        code: 200,
        success: true,
        message: 'setting successfully updated.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'setting was not updated.',
        data: nil
      }
    end
    elsif(!params[:mute_chat].blank? && !params[:mute_notifications].blank?)
      if request_user.update!(mute_chat: mute_chat, mute_notifications: mute_notifications)
      render json: {
        code: 200,
        success: true,
        message: 'setting successfully updated.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'setting was not updated.',
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: 'Either mute_notifications or mute_chat is required.',
        data: nil
      }
    end
  end

  private

  def find_user
    @user = User.find_by_email!(params[:email])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'User not found' }, status: :not_found
  end

  def user_params
    params.permit(:first_name,:last_name,:avatar, :email,:phone_number, :dob, :app_user,:image_link)
  end

  def profile_params

  end

 def profile_update_params
  params.permit(:avatar)
 end
 

 def getRoles
   @roles = Role.all
 end

 def send_verification_email(user)
    @code = user.verification_code 
    @url = "#{ENV['BASE_URL']}/api/v1/auth/verify-code?email=#{user.email}&&verification_code=#{@code}"
    if UserMailer.with(user: user).verification_email(user,@url).deliver_now#UserMailer.deliver_now
     true   
  else
    false
  end
end

# def generate_code
#   (SecureRandom.random_number(9e5) + 1e5).to_i
# end
end
