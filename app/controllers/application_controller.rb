class ApplicationController < ActionController::Base

  include ActionView::Helpers::NumberHelper
  # include ActionController::MimeResponds
  # require 'ruby-graphviz'
    #protect_from_forgery with: :null_session for api
    def request_status(sender,recipient)
      friend_request = FriendRequest.where(user_id: sender.id).where(friend_id: recipient.id).first
      if friend_request
       if friend_request.status == 'pending' || friend_request.status == 'accepted'
        true
       end
      else
        false
      end
  end

  def current_user
    user = User.find(session[:user_id]) if session[:user_id] 
  end

  helper_method :current_user
  # push variable to gon in order to make them available for js
  

  def SetJsVariables
    if current_user
       channel = current_user.id
       name = get_full_name(current_user)
    end
    gon.push({
    :authenticity_token => form_authenticity_token,
    :current_user_channel =>  channel,
    :publish_key =>  ENV['PUBLISH_KEY'],
    :subscribe_key =>  ENV['SUBSCRIBE_KEY'],
    :current_user_name => name
   })
  end

  def generate_code
    code = SecureRandom.hex(10)
  end

  def generate_six_digit_code
    code = rand(100 ** 6)
  end

  def blocked_event?(request_user, event)
    setting = request_user.block_events.where(resource: event).first
    if setting
     blocked = setting.is_on
    else
      false
    end      
  end


  def event_chat_muted?(request_user, event)
    setting = request_user.mute_chat_for_events.where(resource: event).first
    if setting
      mute = setting.is_on
     else
       false
     end   
  end

  def blocked_user?(request_user, user)
    setting = request_user.block_users.where(resource: user).first
    if setting
      blocked = setting.is_on
      if blocked
        mutually_blocked_users = [request_user, user]
        if mutually_blocked_users.include? request_user
          true
        end
      else
        false 
      end
     else
       false
     end     
  end


  def user_chat_muted?(request_user, user)
    setting = request_user.mute_chat_for_users.where(resource: user).first
    if setting
      mute = setting.is_on
     else
       false
     end   
  end

  def is_removed_offer?(request_user, offer)
    setting = request_user.remove_offers.where(resource: offer).first
    if setting
      removed = setting.is_on
    else
      false
    end
  end

  def is_removed_competition?(request_user, competition)
    setting = request_user.remove_competitions.where(resource: competition).first
    if setting
      removed = setting.is_on
    else
      false
    end
  end

  def is_removed_pass?(request_user, pass)
    setting = request_user.remove_passes.where(resource: pass).first
    if setting
      removed = setting.is_on
    else
      false
    end
  end

  def is_followed(user)
    if request_user
     request_user.followings.include? user
    else
     false
    end
   end

   def is_friend?(request_user,friend)
    friend_request = FriendRequest.where(friend_id: friend.id).where(status: 'accepted').first
    if friend_request
      true
    else
      false
    end
  end

   def get_dummy_avatar
     'https://pickaface.net/gallery/avatar/45425654_200117_1657_v2hx2.png'
   end



  def string_to_sym(string)
    string.parameterize.underscore.to_sym
  end

  def is_business?(user)
    role_ids = user.roles.map {|role| role.id }
    role_ids.include? 2  
  end

  def get_full_name(user)
    if is_business?(user)
      name = user.business_profile.profile_name
    else
      name = user.profile.first_name + " " + user.profile.last_name    
     end
  end

  def is_admin_or_super_admin?(user)
    role_ids = user.roles.map {|role| role.id }
    if role_ids.include? 3 then true else false end || if role_ids.include? 4 then true else false end
   
  end


  def get_business_object(user)
    object = {
      "id" => user.id,
      "profile_name" => user.business_profile.profile_name,
      "contact_name" =>  user.business_profile.contact_name,
      'first_name' => user.business_profile.profile_name,
      'last_name' => '',
      "email" => user.email,
      "avatar" => user.avatar,
      "phone_number" => user.phone_number,
      "app_user" => user.app_user,
      "is_email_verified" => user.is_email_verified,
      "web_user" => user.web_user,
      "vat_number" => user.business_profile.vat_number,
      "charity_number" => user.business_profile.charity_number,
      "address" => user.business_profile.address,
      "about" => user.business_profile.about,
      "twitter" => user.business_profile.twitter,
      "facebook" => user.business_profile.facebook,
      "linkedin" => user.business_profile.linkedin,
      "website" => user.business_profile.website,
      "instagram" => user.business_profile.instagram,
      "is_charity" => user.business_profile.is_charity,
      "is_ambassador" => user.business_profile.is_ambassador,
      "is_request_sent" => false,
      "is_my_following" => is_my_following?(user),
      "role" => 2, 
      "is_my_friend" => false,
      "mutual_friends_count" => 0
    }
  end


  def get_user_object(user)

    object = {
      "id" => user.id,
      "first_name" => user.profile.first_name,
      "last_name" =>  user.profile.last_name,
      "email" => user.email,
      "avatar" => user.avatar,
      "phone_number" => user.phone_number,
      "app_user" => user.app_user,
      "is_email_verified" => user.is_email_verified,
      "web_user" => user.web_user,
      "about" => user.profile.about,
      "twitter" => user.profile.twitter,
      "facebook" => user.profile.facebook,
      "snapchat" => user.profile.snapchat,
      "instagram" => user.profile.instagram,
      "linkedin" => user.profile.linkedin,
      "youtube" => user.profile.youtube,
      "is_email_subscribed" => user.profile.is_email_subscribed,
      "is_ambassador" => user.profile.is_ambassador,
      "earning" => user.profile.earning,
      "location" => user.profile.location,
      "lat" => user.profile.lat,
      "lng" => user.profile.lng,
      "device_token" => user.profile.device_token,
      "ranking" => user.profile.ranking,
      "gender" => user.profile.gender,
      "dob" => user.profile.dob.to_date,
      "is_request_sent" => request_status(request_user, user),
      "role" => 5,
      "is_my_following" => false,
      "is_my_friend" => is_my_friend?(user),
      "mutual_friends_count" => user.friends.size
    }

  end


  def get_event_object(event)
     location = {
       "name" => event.location,
       "geometry" => {
          "lat" => event.lat,
          "lng" => event.lng
       }
     }

     admission_resources = []
     #free tickets
      free_tickets = event.tickets.where(ticket_type: 'free')
     if !free_tickets.blank?
      free_tickets.each do |ticket|
       
        fields = []
        fields << {
          "id" => ticket.id,
          "title" => ticket.title,
          "quantity" => ticket.quantity,
          "per_head" => ticket.per_head,
        }

        resource = {
          "name" => "free",
          "fields" => fields
        }

        admission_resources.push(resource)
        
      end #each
    end #if not blank

     #paid tickets
     paid_tickets = event.tickets.where(ticket_type: 'paid')
     if !paid_tickets.blank?
      paid_tickets.each do |ticket|
       
        fields = []
        fields << {
          "id" => ticket.id,
          "title" => ticket.title,
          "quantity" => ticket.quantity,
          "per_head" => ticket.per_head,
          "price" => ticket.price
        }

        resource = {
          "name" => "paid",
          "fields" => fields
        }

        admission_resources.push(resource)
      end #each
    end #if not blank

     #pay at door
     pay_at_door = event.tickets.where(ticket_type: 'pay_at_door')
     if !pay_at_door.blank?
      pay_at_door.each do |ticket|
       
        fields = []
        fields << {
          "id" => ticket.id,
          "start_price" => ticket.start_price,
          "end_price" => ticket.end_price
        }

        resource = {
          "name" => "pay_at_door",
          "fields" => fields
        }

        admission_resources.push(resource)
        
      end #each
    end #if not blank

    #passes

    if !event.passes.blank?
      event.passes.each do |pass|
        fields = []
        fields << {
          "id" => pass.id,
          "title" => pass.title,
          "description" => pass.description,
          "valid_from" => pass.valid_from,
          "valid_to" => pass.valid_to,
          "quantity" =>  pass.quantity,
          "ambassador_rate" => pass.ambassador_rate 
        }

        resource = {
          "name" => "pass",
          "fields" => fields
        }

        admission_resources.push(resource)
      end #each
    end #not blank

    object = {
      "id" => event.id,
      "name" => event.name,
      "start_date" => event.start_date,
      "end_date" => event.end_date,
      "start_time" => event.start_time,
      "end_time" => event.end_time,
      "event_type" => event.event_type,
      "allow_chat" => event.allow_chat,
      "event_forwarding" => event.event_forwarding,
      "over_18" => event.over_18,
      "image" => event.image,
      "description" => event.description,
      "categories" => event.categories,
      "location" => location,
      "admission_resources" => admission_resources,
      "event_attachments" => event.event_attachments,
      "sponsors" => event.sponsors
    }
  end

  def get_pass_object(pass)
    object = {
      id: pass.id,
      title: pass.title,
      host_name: pass.event.user.business_profile.profile_name,
      host_image: pass.event.user.avatar,
      event_name: pass.event.name,
      event_image: pass.event.image,
      event_location: pass.event.location,
      event_start_time: pass.event.start_time,
      event_end_time: pass.event.end_time,
      event_date: pass.event.start_date,
      ambassador_name: pass.ambassador_name,
      is_added_to_wallet: is_added_to_wallet?(pass.id),
      validity: pass.validity.strftime(get_time_format).to_s,
      grabbers_count: pass.wallets.size
    }
  end


  def get_special_offer_object(offer)
    object = {
      id: offer.id,
      title: offer.title,
      sub_title: offer.sub_title,
      location: offer.location,
      date: offer.date,
      time: offer.time,
      lat: offer.lat,
      lng: offer.lng,
      image: offer.image.url,
      creator_name: get_full_name(offer.user),
      creator_image: offer.user.avatar,
      description: offer.description,
      validity: offer.validity.strftime(get_time_format),
      end_time: offer.validity.strftime(get_time_format), 
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: get_grabbers_friends_count(offer)
    }
  end


  def get_competition_object(competition)
    object = {
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
        is_entered: is_entered_competition?(competition.id),
        participants_stats: get_participants_stats(competition),
        creator_name: competition.user.business_profile.profile_name,
        creator_image: competition.user.avatar,
        creator_id: competition.user.id,
        is_followed: is_followed(competition.user),
        validity: competition.validity.strftime(get_time_format)
    }
  end

   # Get formated date time according to specific format
  def get_formated_datetime(datetime, format = "%Y-%m-%dT%H:%M:%S.%d0Z")
    if(datetime.is_a?(String))
      formated = DateTime.parse(datetime).strftime(format)
    else
       formated = datetime.strftime(format)
    end
   end

   def get_time_format
    format = "%Y-%m-%dT%H:%M:%S.%d0Z"
   end

   def create_activity(actor, action, resource, resource_type, resource_url,resrource_title, method, action_type = '')
    
   if activity = ActivityLog.create!(user: actor, action: action, resource: resource, resource_type: resource_type, browser: request.env['HTTP_USER_AGENT'], ip_address: request.env['REMOTE_ADDR'], params: params.inspect,url: resource_url, method: method, resource_title: resrource_title, action_type: action_type)
    true
   else
    activity.errors.full_messages
   end
  end


  def ambassador_stats(offer, user)
    @shared_offers = []
    @stats = {}

    @forwardings = user.offer_forwardings.each do |forward|
      @shared_offers.push(forward.offer)
    end

    @sharings = user.offer_shares.each do |share|
      @shared_offers.push(share.offer)
    end

    if @shared_offers.include? offer
        in_wallet_count = Wallet.where(offer_id: offer.id).size
        @stats["in_wallet_count"] = in_wallet_count
        redeemed_count = Redemption.where(offer_id: offer.id).size
        @stats["redeemed_count"] = redeemed_count
        per_offer_earning = offer.ambassador_rate * redeemed_count
        if per_offer_earning.blank? then per_offer_earning = 0 end
        @stats['per_offer_earning'] = per_offer_earning
       
    else
      @stats['info'] = "You didn't share this offer."
    end

   @stats
  end

  def get_ambassador_gives_away(user)
    @businesses = user.ambassador_businesses
    @passes = []
    @special_offers = []
    @offers = []
    @businesses.each do |business|
      if !business.passes.blank?
      business.passes.not_expired.order(created_at: 'DESC').each do |pass| 
        @passes << {
          id: pass.id,
          type: 'pass',
          title: pass.title,
          host_name: business.business_profile.profile_name,
          host_image: business.avatar,
          event_name: pass.event.name,
          event_image: pass.event.image,
          event_location: pass.event.location,
          event_start_time: pass.event.start_time,
          event_end_time: pass.event.end_time,
          event_date: pass.event.start_date,
          ambassador_name: pass.ambassador_name,
          is_added_to_wallet: is_added_to_wallet?(pass.id),
          validity: pass.validity.strftime(get_time_format).to_s,
          grabbers_count: pass.wallets.size,
          ambassador_stats: ambassador_stats(pass, request_user),
          ambassador_rate: pass.ambassador_rate,
          quantity: pass.quantity,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: pass.created_at,
          business: get_business_object(business) 
        }
        end
      end #not empty

      if !business.special_offers.blank?
        business.special_offers.not_expired.order(created_at: 'DESC').each do |offer|
        @special_offers << {
          id: offer.id,
          type: 'special_offer',
          title: offer.title,
          sub_title: offer.sub_title,
          location: offer.location,
          date: offer.date,
          time: offer.time,
          lat: offer.lat,
          lng: offer.lng,
          image: offer.image.url,
          creator_name: offer.user.business_profile.profile_name,
          creator_image: offer.user.avatar,
          description: offer.description,
          validity: offer.validity.strftime(get_time_format),
          end_time:  offer.validity.strftime(get_time_format), 
          grabbers_count: offer.wallets.size,
          ambassador_stats: ambassador_stats(offer, request_user),
          is_added_to_wallet: is_added_to_wallet?(offer.id),
          grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
          ambassador_rate: offer.ambassador_rate,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: offer.created_at,
          business: get_business_object(business) 
        }
        end
      end #not empty
    end

    if !@passes.blank?
      @passes.each do  |pass|
        @offers.push(pass)
      end
   end #not empty

   if !@passes.blank?
    @special_offers.each do  |offer|
      @offers.push(offer)
    end
  end#not empty
    @offers
      
end

  def is_ambassador?(user)
    user.profile.is_ambassador
  end

  def is_added_to_wallet?(pass_id)
    if request_user
    wallet = request_user.wallets.where(offer_id: pass_id).where(offer_type: 'Pass')
    if !wallet.blank?
      true
    else
      false
    end
  else
     false
  end
  end

  def get_grabbers_friends_count(offer)
    if request_user
      offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size
    else
      0
    end
  end


  def is_entered_competition?(competition_id)
    if request_user
     reg = Registration.where(user_id: request_user).where(event_id: competition_id).where(event_type: 'Competition')
     if !reg.blank?
       true
     else
       false
     end
    else
      false
    end
   end


   def get_participants_stats(competition) 
    participants = []
    if !competition.registrations.blank?
    competition.registrations.each do |reg|
      participants.push(reg.user.avatar)
    end #each
  end #if
   @stats = []
   @stats << {
     "participants_avatars" => participants,
     "participants_count" => participants.size
   }
   @stats
  end

  def is_attending?(event)
    if request_user
     if request_user.events_to_attend.include? event
       true
     else
       false
     end
   else
     false
   end
   end
 
   def is_interested?(event)
    if request_user
     if request_user.interested_in_events.include? event
       true
     else
       false
     end
   else
      false
   end
   end
 
   
 
    def is_ticket_purchased(ticket_id)
      if request_user
       ticket = TicketPurchase.where(user_id: request_user.id).where(ticket_id: ticket_id)
       if !ticket.blank?
         true
       else
         false
       end
     else
       false
     end
    end
 
   def get_event_passes_grabbers(e)
      @grabbers_avatars = []
      @total_count = 0
     e.passes.each do |pass|
       @total_count  = @total_count + pass.wallets.size
       pass.wallets.each do |w|
         @grabbers_avatars.push(w.user.avatar)
       end      
     end
     stats = []
     stats << {
       "grabbers_avatars" => @grabbers_avatars,
       "total_grabbers_count" => @total_count
     }
     stats
   end

   def not_me?(user)
    user != request_user
   end
 
  
 
  def get_passes_grabbers_friends_count(e)
   if request_user
     e.passes.map {|pass| pass.wallets.map { |wallet| if (request_user.friends.include? wallet.user) then wallet.user end } }.size
   else
     @empty = []
   end
  end
 
  def get_mute_chat_status(event)
   if request_user  
     setting = request_user.mute_chat_for_events.where(resource: event).first
     if setting
      is_mute = setting.is_on
     else
      false
     end
   else
     false
   end
  end
 
  def get_mute_notifications_status(event)
    if request_user
      setting = request_user.mute_notifications_for_events.where(resource: event).first
      if setting
        is_mute = setting.is_on
      else
        false
      end
    else
     false
    end
  end


  def get_request_status(business_id)
    ar = AmbassadorRequest.where(business_id: business_id).where(user_id: request_user.id).first
    if ar
    ar.status 
    else
      'signup'
    end
  end


  def get_formated_price(number)
    number_with_precision(number, :precision => 2)
  end

  helper_method :SetJsVariables
  helper_method :is_admin_or_super_admin?
  helper_method :create_activity
  helper_method :generate_code
  helper_method :get_full_name

end
