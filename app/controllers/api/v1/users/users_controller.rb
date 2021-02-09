class Api::V1::Users:Settings::UsersController < Api::V1::ApiMasterController
  before_action :authorize_request, except: :create
  before_action :checkout_logout, except: :create
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  # GET /users

  api :GET, '/api/v1/users', 'View All Users - Token Required'

  def index
    all_users = []
    app = mobile_users.page(params[:page]).per(100).map  { |user| all_users.push(get_user_object(user)) }
    business = business_users.page(params[:page]).per(20).map { |user| all_users.push(get_business_object(user)) }

    render json: {
      code: 200,
      success: true,
      data: {
        users: all_users
      }
    }
  end

  api :GET, '/api/v1/get-users-having-common-fields', 'To update a user profile'

  def get_users_having_common_fields
    users = []
    User.all.each do |user|
     users << {
      "id" =>  user.id,
      "profile_name" => get_full_name(user),
      "email" => user.email,
      "avatar" => user.avatar,
      "phone_number" => user.phone_number,
      "roles" => get_user_role_names(user)
     }
    end

    render json: {
      code: 200,
      success: true,
      data: {
        users: users
      }
    }
  end

  # GET /users/{username}
  def show
    render json: @user, status: :ok
  end

  api :POST, '/api/v1/users/create-user', 'To SignUp/Register'
  param :first_name, String, :desc => "First Name", :required => true
  param :last_name, String, :desc => "last Name", :required => true
  param :dob, String, :desc => "DOB", :required => true
  param :gender, String, :desc => "Gender", :required => true
  param :role_id, Integer, :desc => "role_id", :required => true
  param :phone_number, String, :desc => "phone_number"
  param :email, String, :desc => "email"
  param :location, String, :desc => "location"
  param :about, String, :desc => "about"
  # POST /users
  def create_user
    required_fields = ['first_name', 'last_name','dob', 'gender', 'role_id']
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
      @user.avatar= params[:avatar]
    end

    @user.phone_number = params[:phone_number]
    @user.email = params[:email]
    @user.location = params[:location]
    @user.about = params[:about]
    @user.password = params[:password]
    @user.uuid = generate_uuid
    if @user.save
      @profile = Profile.new
      @profile.dob = params[:dob]
      @profile.user = @user
      @profile.first_name = params[:first_name]
      @profile.last_name = params[:last_name]
      @profile.gender = params[:gender]
      @profile.save
      @profile_data = {}
      @profile_data['id'] = @user.id
      @profile_data["first_name"] = @user.profile.first_name
      @profile_data["last_name"] = @user.profile.last_name
      @profile_data["avatar"] = @user.avatar

      @user.social_media.new
      @user.save
       #Also save default setting
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

       setting_name_values.each do |name|
         new_setting = Setting.create!(user_id: @user.id, name: name, is_on: true)
       end #each

       if params[:is_email_subscribed] ==  'true'
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

       #create role
       assignment = @user.assignments.create!(role_id: params[:role_id])

      render json: {
            code: 200,
            success: true,
            message: "Registered successfully.",
            data: {
              user: @profile_data,
              token: encode(user_id: @user.id),
              email_sent: email_sent
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
      #create_activity("updated profile picture.", @user, "User")
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

  api :POST, '/api/v1/users/update-user', 'To SignUp/Register'
  param :id, Integer, :desc => "The Id of the user", :required => true
  param :first_name, String, :desc => "First Name", :required => true
  param :last_name, String, :desc => "last Name", :required => true
  param :dob, String, :desc => "DOB", :required => true
  param :gender, String, :desc => "Gender", :required => true
  param :role_id, Integer, :desc => "role_id", :required => true
  param :phone_number, String, :desc => "phone_number"
  param :email, String, :desc => "email"
  param :location, String, :desc => "location"
  param :about, String, :desc => "about"

  def update_profile
    user = User.find(params[:id])
    profile = user.profile
    social = user.social_media
    user.profile.first_name = params[:first_name]
    user.profile.last_name = params[:last_name]
    user.avatar = params[:avatar]
    user.profile.gender = params[:gender]
    user.about = params[:about]
    user.profile.dob = params[:dob]
    user.phone_number = params[:phone_number]
    user.email = params[:email]
    user.password = params[:password]
    user.location = params[:location]

    @social = user.social_media

    @social.youtube = params[:youtube]
    @social.linkedin = params[:linkedin]
    @social.instagram = params[:instagram]
    @social.twitter = params[:twitter]
    @social.snapchat = params[:snapchat]
    @social.facebook = params[:facebook]

  if user.save && @social.save
   # create_activity("updated profile.", profile, "Profile")
   profile_object = {
    'first_name' => user.profile.first_name,
    'last_name' => user.profile.last_name,
    'avatar' => user.avatar,
    'location' => eval(user.location),
    'about' => user.about,
    'dob' => user.profile.dob.to_date,
    'roles' => user.role_ids,
    'gender' => user.profile.gender,
    'mobile' => user.phone_number,
    'email' => user.email,
    'social' => user.social_media
  }

    render json: {
      code: 200,
      success: true,
      message: "successfully updated.",
      data: {
        user: user,
        profile: profile_object
      }
    }
  else
    render json: {
      code: 400,
      success: false,
      message: {  user_errors: user.errors.full_messages },
      data: nil
    }
  end
end

  api :GET, '/api/v1/users/get-profile', 'To get your own profile - Token is required'

  def get_profile
    user = request_user
      profile = {
          'id' => user.id,
          'first_name' => user.profile.first_name,
          'last_name' => user.profile.last_name,
          'avatar' => eval(user.avatar),
          'location' => user.location,
          'about' => user.about,
          'dob' => user.profile.dob.to_date,
          'roles' => user.role_ids,
          'gender' => user.profile.gender,
          'mobile' => user.phone_number,
          'email' => user.email,
          'social' => user.social_media,
          'friends_count' => user.friends.size,
          'follows_count' => user.followings.size,
          'followers_count' => user.followers.size
      }

      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          profile: profile,
          user: request_user
        }
      }
end

  api :POST, '/api/v1/users/get-others-profile', 'To get a mobile user profile'
  param :user_id, Integer, :desc => "User ID", :required => true

 def get_others_profile
  if !params[:user_id].blank?
  user = User.find(params[:user_id])
  profile = {}

  profile['user_id'] = user.id
  profile['first_name'] = user.profile.first_name
  profile['last_name'] = user.profile.last_name
  profile['avatar'] = user.avatar
  profile['about'] = user.about
  profile['dob'] = user.profile.dob.to_date
  profile['roles'] = user.role_ids
  profile['gender'] = user.profile.gender
  profile['mobile'] = user.phone_number
  profile['email'] = user.email
  profile['location'] = eval(user.location)
  profile['social'] = user.social_media
  profile['friends_count'] = user.friends.size
  profile['follows_count'] = user.followings.size
  profile['followers_count'] = user.followers.size

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

  api :POST, '/api/v1/users/user-activity-logs', 'To get user get activity logs'
  param :user_id, Integer, :desc => "User ID", :required => true

 def activity_logs
   if !params[:user_id].blank?
     user = User.find(params[:user_id])
     activity_logs = []
     user.activity_logs.sort_by_date.page(params[:page]).per(10).each do |log|
      resource = {}
      case log.resource_type
      when 'ChildEvent'
       resource['id'] = log.resource_id
       resource['name'] = log.resource.title
       resource['host_name'] = get_full_name(log.resource.user)
       resource['location'] = eval(log.resource.location)
       resource['start_date'] = log.resource.start_date
       resource['interested_people_count'] = log.resource.interest_levels.size

      when 'FriendRequest'
      resource["friend_name"] = get_full_name(log.resource.user)
      resource['friends_count'] = log.resource.user.friends.size
      resource['mutual_friends_count'] = get_mutual_friends(request_user, log.resource.user).size

      when 'Follow'
      resource['name'] = get_full_name(log.resource.following)
      resource['followers_count'] = log.resource.following.followers.size
      resource['mututal_followers_count'] = request_user.followings.size

      when 'AmbassadorRequest'
        resource['profile_name'] = log.resource.business.business_profile.profile_name

      when 'Pass'
        resource['title'] = log.resource.title
        resource['host_name'] = get_full_name(log.resource.user)
        resource['location'] = eval(log.resource.event.location)
        resource['start_date'] = log.resource.event.start_date
        resource['grabbers_counts'] = log.resource.wallets.size

      when 'SpecialOffer'
        resource['title'] = log.resource.title
        resource['host_name'] = get_full_name(log.resource.user)
        resource['location'] = eval(log.resource.location)
        resource['start_date'] = log.resource.date
        resource['grabbers_counts'] = log.resource.wallets.size

      when 'Competition'
        resource['title'] = log.resource.title
        resource['host_name'] = get_full_name(log.resource.user)
        resource['location'] = eval(log.resource.location)
        resource['validity'] = log.resource.validity_time

      when 'OfferForwarding'
        resource['title'] = log.resource.offer.title
        resource['host_name'] = get_full_name(log.resource.user)
        resource['forwarded_to'] =  get_full_name(log.resource.recipient)

      else
        "do nothing"
      end #case

      activity_logs << {
        "id" => log.id,
        "action_type" => log.action_type,
        "action" => log.action,
        "resource_type" => log.resource_type,
        "resource" => resource,
        "created_at" => log.created_at

      }
    end #each

     render json: {
       code: 200,
       success: true,
       message: '',
       data: {
         activity_logs: activity_logs
       }
     }
   else
    render json: {
      code: 400,
      success: false,
      message: 'user_id is required field.',
      data: nil
    }
   end
 end
  api :POST, '/api/v1/users/user-attending', 'User Events to attend list'
  param :user_id, Integer, :desc => "User ID", :required => true

 def attending
   if !params[:user_id].blank?

     user = User.find(params[:user_id])
     attending = user.events_to_attend.page(params[:page]).per(30).map {|event| get_simple_event_object(event) }

     render json: {
       code: 200,
       success: true,
       message: '',
       data: {
         attending: attending
       }
     }
   else
    render json: {
      code: 400,
      message: "user_id is required field.",
      data: nil
    }
  end
 end

  

  api :get, '/api/v1/users/my-activity-logs', 'To get my activity logs'

 def my_activity_logs
    user = request_user
    activity_logs = []
    user.activity_logs.sort_by_date.page(params[:page]).per(10).each do |log|
     resource = {}
     case log.resource_type
     when 'Event'
      resource['id'] = log.resource_id
      resource['name'] = log.resource.title
      resource['host_name'] = get_full_name(log.resource.user)
      resource['location'] = eval(log.resource.location)
      resource['start_date'] = log.resource.start_date
      resource['interested_people_count'] = log.resource.interest_levels.size

     when 'FriendRequest'
     resource["friend_name"] = get_full_name(log.resource.user)
     resource['friends_count'] = log.resource.user.friends.size
     resource['mutual_friends_count'] = get_mutual_friends(request_user, resource.user).size

     when 'Follow'
     resource['name'] = get_full_name(log.resource.following)
     resource['followers_count'] = log.resource.following.followers.size
     resource['mututal_followers_count'] = request_user.followings.size

     when 'AmbassadorRequest'
       resource['profile_name'] = log.resource.business.business_profile.profile_name

     when 'Pass'
       resource['title'] = log.resource.title
       resource['host_name'] = get_full_name(log.resource.user)
       resource['location'] = eval(log.resource.event.location)
       resource['start_date'] = log.resource.event.start_date
       resource['grabbers_counts'] = log.resource.wallets.size

     when 'SpecialOffer'
       resource['title'] = log.resource.title
       resource['host_name'] = get_full_name(log.resource.user)
       resource['location'] = eval(log.resource.location)
       resource['start_date'] = log.resource.date
       resource['grabbers_counts'] = log.resource.wallets.size

     when 'Competition'
       resource['title'] = log.resource.title
       resource['host_name'] = get_full_name(log.resource.user)
       resource['location'] = eval(log.resource.location)
       resource['validity'] = log.resource.validity_time

     when 'OfferForwarding'
       resource['title'] = log.resource.offer.title
       resource['host_name'] = get_full_name(log.resource.user)
       resource['forwarded_to'] =  get_full_name(log.resource.recipient)

     else
       "do nothing"
     end #case

     activity_logs << {
       "id" => log.id,
       "action_type" => log.action_type,
       "action" => log.action,
       "resource_type" => log.resource_type,
       "resource" => resource,
       "created_at" => log.created_at

     }
   end #each

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        activity_logs: activity_logs
      }
    }

end

 


 #own profile
 def get_business_profile
      user = request_user
      profile = {}
      offers = {}
      offers['special_offers'] = user.special_offers
      offers['passes'] = user.passes
      profile['first_name'] = user.business_profile.profile_name
      profile['last_name'] = ''
      profile['avatar'] = user.avatar
      profile['about'] = user.about
      profile['location'] = eval(user.location)
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

  api :POST, '/api/v1/user/users/get-others-business-profile', 'To get a business profile'
  param :user_id, Integer, :desc => "User ID", :required => true

 def get_others_business_profile
  if !params[:user_id].blank?
  user = User.find(params[:user_id])
  profile = {}
  status = get_request_status(user.id)
  profile['id'] = user.id
  profile['profile_name'] = user.business_profile.profile_name
  profile['first_name'] = user.business_profile.profile_name
  profile['last_name'] = ''
  profile['avatar'] = user.avatar
  profile['address'] = eval(user.location)
  profile["social"] = user.social_media
  profile['website'] = user.business_profile.website
  profile['followers_count'] = user.followers.size
  profile['events_count'] = user.events.size
  profile['competitions_count'] = user.competitions.size
  profile['offers_count'] = user.special_offers.size
  profile['news_feeds'] = user.news_feeds
  profile['ambassador_request_status'] = status
  profile['is_ambassador'] = false
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

  api :GET, '/api/v1/users/get-activity-logs', 'To get the activity logs'

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

  api :POST, '/api/v1/users/update-device-token', 'To update a device token'
  param :device_token, String, :desc => "Device Token", :required => true

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

  api :POST, '/api/v1/users/update-current-location', 'To update a current location'
  param :location, String, :desc => "Location of the user", :required => true

  def update_current_location
    if !params[:location].blank?
      user = request_user
      if user.update!(location: params[:location])
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
        message: 'Location is a required fields',
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


  def privacy_policy
    url = Rails.root + "/uploads/privacty_policy/mygo_privacty_policy.pdf"
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        url: url
      }
    }
  end

  api :GET, '/api/v1/get-phone-numbers', 'To get phone number list'

  def get_phone_numbers
    @phone_numbers = User.all.map {|user| user.phone_number }
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        phone_numbers: @phone_numbers
      }
    }
  end

  api :POST, '/api/v1/users/update-profile-picture', 'Update Profile Picture'
  param :avatar, String, :desc => "Avatar", :required => true

  def update_profile_pictures
    if @update = request_user.update!(avatar: params[:avatar])
      render json: {
        code: 200,
        success: true,
        message: 'Profile picture successfully updated.',
        data: {
          picture: request_user.avatar
        }
      }
    else
      render json: {
        code: 400,
        success: false,
        message: @update.errors.full_messages,
        data: nil
      }
    end
  end


 def delete_account
  if !params[:user_id].blank?
    if User.find(params[:user_id]).destroy
      render json: {
        code: 200,
        success: true,
        message: 'Account deleted successfully.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "Account deletion failed.",
        data: nil
      }
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


private

  def find_user
    @user = User.find_by_email!(params[:email])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'User not found' }, status: :not_found
  end

  def user_params
    params.permit(:first_name,:last_name,:avatar, :email,:phone_number,:email, :dob, :app_user,:image_link)
  end

  def profile_params

  end

 def profile_update_params
  params.permit(:avatar)
 end


 def getRoles
   @roles = Role.all
 end

  api :GET, '/api/v1/auth/send-verification-email', 'Send verification code to verify email'
  param :email, String, :desc => "Email", :required => true


 def send_verification_email(user)
    @code = user.verification_code
    base_url = request.base_url
    @url = "#{base_url}/api/v1/auth/verify-code?email=#{user.email}&&verification_code=#{@code}"
    # @url = "#{ENV['BASE_URL']}/api/v1/auth/verify-code?email=#{user.email}&&verification_code=#{@code}"
    if UserMailer.with(user: user).verification_email(user,@url).deliver_now#UserMailer.deliver_now
     true
  else
    false
  end
end



def has_passes?(event)
  !event.passes.blank?
end

# def generate_code
#   (SecureRandom.random_number(9e5) + 1e5).to_i
# end
end
