class Api::V1::UsersController < Api::V1::ApiMasterController
  before_action :authorize_request, except: :create
  before_action :checkout_logout, except: :create
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  # GET /users
  def index
    all_users = []
    app = User.app_users.map  { |user| all_users.push(get_user_object(user)) }
    business = User.web_users.map { |user| all_users.push(get_business_object(user)) }
      
    render json: {
      code: 200,
      success: true,
      data: {
        users: all_users
      }
    }
  end


  def get_users_having_common_fields
    users = []
    User.all.each do |user|
     users << {
      "id" =>  user.id,
      "profile_name" => get_full_name(user),
      "email" => user.email,
      "avatar" => user.avatar,
      "phone_number" => user.phone_number,
      "app_user" => user.app_user,
      "is_email_verified" => user.is_email_verified,
      "web_user" => user.web_user
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

  # POST /users
  def create

    required_fields = ['first_name', 'last_name','app_user','dob', 'device_token', 'gender','is_email_subscribed', 'type']
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
   
    @user.app_user = params[:app_user]
    @user.phone_number = params[:phone_number]
    @user.email = params[:email]
    @user.verification_code = generate_code
    @user.stripe_state = generate_code
    if @user.save 
      @profile = Profile.new
      @profile.dob = params[:dob]
      @profile.user = @user
      @profile.first_name = params[:first_name]
      @profile.last_name = params[:last_name]
      @profile.device_token = params[:device_token]
      @profile.gender = params[:gender]
      if !params[:location].blank?
      @profile.location = params[:location]
      @profile.lat = params[:lat]
      @profile.lng = params[:lng]
      end
      @profile.is_email_subscribed = params[:is_email_subscribed]
      @profile.save
      @profile_data = {}
      @profile_data['id'] = @user.id
      @profile_data["first_name"] = @user.profile.first_name
      @profile_data["last_name"] = @user.profile.last_name
      @profile_data["avatar"] = @user.avatar
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
       assignment = @user.assignments.create!(role_id: params[:type])
       
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

  def update_profile
    params.permit(:avatar)
    user = request_user
    profile = user.profile
    user.profile.first_name = params[:first_name]
    user.profile.last_name = params[:last_name]
    user.avatar = params[:avatar] 
    user.profile.gender = params[:gender]
    profile.about = params[:about]
    profile.add_social_media_links = params[:add_social_media_links]
    profile.facebook = params[:facebook]
    profile.twitter = params[:twitter]
    profile.snapchat = params[:snapchat]
    profile.linkedin = params[:linkedin]
    profile.youtube = params[:youtube]
    profile.instagram = params[:instagram]
    user.profile.dob = params[:dob]
    user.phone_number = params[:phone_number]
    user.email = params[:email]

  if profile.save && user.save
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
      activity_logs = []
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
        "price_type" => event.price_type,
        "price" => get_formated_price(event.price),
        "additional_media" => event.event_attachments,
        "created_at" => event.created_at,
        "updated_at" => event.updated_at,
        "host" => event.host,
        "host_image" => event.user.avatar,
        "interest_count" => event.interested_interest_levels.size,
        "going_count" => event.going_interest_levels.size,
        "demographics" => get_demographics(event),
        'has_passes' => has_passes?(event)
      }
    end

    user.interested_in_events.each do |event|
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
        "price_type" => event.price_type,
        "price" => event.price,
        "additional_media" => event.event_attachments,
        "created_at" => event.created_at,
        "updated_at" => event.updated_at,
        "host" => event.host,
        "host_image" => event.user.avatar,
        "interest_count" => event.interested_interest_levels.size,
        "going_count" => event.going_interest_levels.size,
        "demographics" => get_demographics(event),
        'has_passes' => has_passes?(event)
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
      creator_name: get_full_name(competition.user),
      creator_image: competition.user.avatar,
      total_entry_count: get_entry_count(user, competition),
      issued_by: get_full_name(competition.user),
      validity: competition.validity
      }
      end

      user.activity_logs.each do |log|
        resource = {}
        case log.resource_type
        when 'Event'
         resource['id'] = log.resource_id
         resource['name'] = log.resource.name
         resource['host_name'] = get_full_name(log.resource.user)
         resource['location'] = log.resource.location
         resource['start_date'] = log.resource.start_date
         resource['interested_people_count'] = log.resource.interest_levels.size

        when 'FriendRequest'
        resource["friend_name"] = get_full_name(log.resource.user)
        resource['friends_count'] = log.resource.user.friends.size
        resource['mutual_friends_count'] = request_user.friends.size

        when 'Follow'
        resource['name'] = get_full_name(log.resource.following)
        resource['followers_count'] = log.resource.following.followers.size
        resource['mututal_followers_count'] = request_user.followings.size

        when 'AmbassadorRequest'
          resource['profile_name'] = log.resource.business.business_profile.profile_name

        when 'Pass'
          resource['title'] = log.resource.title
          resource['host_name'] = get_full_name(log.resource.user)
          resource['location'] = log.resource.event.location
          resource['start_date'] = log.resource.event.start_date
          resource['grabbers_counts'] = log.resource.wallets.size

        when 'SpecialOffer'
          resource['title'] = log.resource.title
          resource['host_name'] = get_full_name(log.resource.user)
          resource['location'] = log.resource.location
          resource['start_date'] = log.resource.date
          resource['grabbers_counts'] = log.resource.wallets.size
          
        when 'Competition'
          resource['title'] = log.resource.title
          resource['host_name'] = get_full_name(log.resource.user)
          resource['location'] = log.resource.location
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
      end


      profile['first_name'] = user.profile.first_name 
      profile['last_name'] = user.profile.last_name
      profile['avatar'] = user.avatar
      profile['lat'] = user.profile.lat
      profile['lng'] = user.profile.lng
      profile['about'] = user.profile.about
      profile['dob'] = user.profile.dob.to_date
      profile['roles'] = user.roles
      profile['gender'] = user.profile.gender
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
      profile['activities'] = activity_logs
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

 def get_others_profile
  if !params[:user_id].blank?
  user = User.find(params[:user_id])
  activity_logs = []
  profile = {}
  attending = []
  competitions = []
  gives_away = []

  if is_ambassador?(user)
   gives_away = get_ambassador_gives_away(user)
  end #is_ambassador if


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
      "price_type" => event.price_type,
      "price" => event.price,
      "additional_media" => event.event_attachments,
      "created_at" => event.created_at,
      "updated_at" => event.updated_at,
      "host" => event.host,
      "host_image" => event.user.avatar,
      "interest_count" => event.interested_interest_levels.size,
      "going_count" => event.going_interest_levels.size,
      "demographics" => get_demographics(event),
      'has_passes' => has_passes?(event)
    }
  end

  user.interested_in_events.each do |event|
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
      "price_type" => event.price_type,
      "price" => event.price,
      "additional_media" => event.event_attachments,
      "created_at" => event.created_at,
      "updated_at" => event.updated_at,
      "host" => event.host,
      "host_image" => event.user.avatar,
      "interest_count" => event.interested_interest_levels.size,
      "going_count" => event.going_interest_levels.size,
      "demographics" => get_demographics(event),
      'has_passes' => has_passes?(event)
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
    creator_name: get_full_name(competition.user),
    creator_image: competition.user.avatar,
    validity: competition.validity,
    total_entry_count: get_entry_count(user, competition),
    issued_by: get_full_name(competition.user)
    
    }
    end

    user.activity_logs.each do |log|
      resource = {}
      case log.resource_type
      when 'Event'
       resource['id'] = log.resource_id
       resource['name'] = log.resource.name
       resource['host_name'] = get_full_name(log.resource.user)
       resource['location'] = log.resource.location
       resource['start_date'] = log.resource.start_date
       resource['interested_people_count'] = log.resource.interest_levels.size

      when 'FriendRequest'
      resource["friend_name"] = get_full_name(log.resource.user)
      resource['friends_count'] = log.resource.user.friends.size
      resource['mutual_friends_count'] = request_user.friends.size

      when 'Follow'
      resource['name'] = get_full_name(log.resource.following)
      resource['followers_count'] = log.resource.following.followers.size
      resource['mututal_followers_count'] = request_user.followings.size

      when 'AmbassadorRequest'
        resource['profile_name'] = log.resource.business.business_profile.profile_name

      when 'Pass'
        resource['title'] = log.resource.title
        resource['host_name'] = get_full_name(log.resource.user)
        resource['location'] = log.resource.event.location
        resource['start_date'] = log.resource.event.start_date
        resource['grabbers_counts'] = log.resource.wallets.size

      when 'SpecialOffer'
        resource['title'] = log.resource.title
        resource['host_name'] = get_full_name(log.resource.user)
        resource['location'] = log.resource.location
        resource['start_date'] = log.resource.date
        resource['grabbers_counts'] = log.resource.wallets.size
        
      when 'Competition'
        resource['title'] = log.resource.title
        resource['host_name'] = get_full_name(log.resource.user)
        resource['location'] = log.resource.location
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
    end

  profile['user_id'] = user.id
  profile['first_name'] = user.profile.first_name 
  profile['last_name'] = user.profile.last_name
  profile['avatar'] = user.avatar
  profile['about'] = user.profile.about
  profile['dob'] = user.profile.dob.to_date
  profile['roles'] = user.roles
  profile['gender'] = user.profile.gender
  profile['mobile'] = user.phone_number
  profile['email'] = user.email
  profile['lat'] = user.profile.lat
  profile['lng'] = user.profile.lng
  profile['facebook'] = user.profile.facebook
  profile['twitter'] = user.profile.twitter
  profile['snapchat'] = user.profile.snapchat
  profile['instagram'] = user.profile.instagram
  profile['linkedin'] = user.profile.linkedin
  profile['youtube'] = user.profile.youtube
  profile['friends_count'] = user.friends.size
  profile['follows_count'] = user.followings.size
  profile['followers_count'] = user.followers.size
  profile['gives_away'] = gives_away

  # if user.is_ambassador to be added later
  #   profile['passes'] = 'to be added after ambassador shcema'
  # end
  profile['competitions'] = competitions
  profile['attending'] = attending
  profile['activities'] = activity_logs
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
      profile['first_name'] = user.business_profile.profile_name 
      profile['last_name'] = ''
      profile['avatar'] = user.avatar
      profile['about'] = user.profile.about
      profile['address'] = user.business_profile.address
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
      events = []
      competitions = []
      status = get_request_status(user.id)
      user.events.each do |e|
        events << {
          'id' => e.id,
          'name' => e.name,
          'description' => e.description,
          'start_date' => e.start_date,
          'end_date' => e.end_date,
          'start_time' => e.start_time,
          'end_time' => e.end_time,
          'price' => get_formated_price(e.price), # check for price if it is zero
          'price_type' => e.price_type,
          'event_type' => e.event_type,
          'additional_media' => e.event_attachments,
          'location' => e.location,
          'lat' => e.lat,
          'lng' => e.lng,
          'image' => e.image,
          'is_interested' => is_interested?(e),
          'is_going' => is_attending?(e),
          'is_followed' => is_followed(e.user),
          'interest_count' => e.interested_interest_levels.size,
          'going_count' => e.going_interest_levels.size,
          'followers_count' => e.user ? e.user.followers.size : nil ,
          'following_count' => e.user ? e.user.followings.size : nil,
          'demographics' => get_demographics(e),
          'passes' =>  @passes,
          'ticket' => @ticket,
          'passes_grabbers_friends_count' =>  get_passes_grabbers_friends_count(e),
          'going_users' => e.going_users,
          "interested_users" => getInterestedUsers(e),
          'creator_name' => e.user.business_profile.profile_name,
          'creator_id' => e.user.id,
          'creator_image' => e.user.avatar,
          'categories' => !e.categories.blank? ? e.categories : @empty,
          'grabbers' => get_event_passes_grabbers(e),
          'sponsors' => e.sponsors,
          "mute_chat" => get_mute_chat_status(e),
          "mute_notifications" => get_mute_notifications_status(e) 
        }
      end

      offers['special_offers'] = user.special_offers.map {|offer| get_special_offer_object(offer) }
      offers['passes'] = user.passes.map {|pass| get_pass_object(pass) }
      profile['id'] = user.id
      profile['profile_name'] = user.business_profile.profile_name
      profile['first_name'] = user.business_profile.profile_name
      profile['last_name'] = ''   
      profile['avatar'] = user.avatar
      profile['address'] = user.business_profile.address
      profile['about'] = user.business_profile.about
      profile['facebook'] = user.business_profile.facebook
      profile['twitter'] = user.business_profile.twitter
      profile['snapchat'] = user.business_profile.snapchat
      profile['instagram'] = user.business_profile.instagram
      profile['linkedin'] = user.business_profile.linkedin
      profile['youtube'] = user.business_profile.youtube
      profile['followers_count'] = user.followers.size
      profile['events_count'] = user.events.size
      profile['competitions_count'] = user.competitions.size
      profile['offers_count'] = user.special_offers.size
      profile['competitions'] = user.competitions.map {|competition| get_competition_object(competition) }
      profile['events'] = events
      profile['offers'] = offers
      profile['news_feeds'] = user.news_feeds
      profile['ambassador_request_status'] = status 
      profile['is_ambassador'] = if get_request_status(user.id) == 'accepted' then true else false end

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
    if update = request_user.profile.update!(device_token: params[:device_token])
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
      if user.profile.update!(lat: params[:lat], lng: params[:lng])
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

 def send_verification_email(user)
    @code = user.verification_code 
    @url = "#{ENV['BASE_URL']}/api/v1/auth/verify-code?email=#{user.email}&&verification_code=#{@code}"
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
