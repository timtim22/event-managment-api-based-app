class ApplicationController < ActionController::Base
  require "pubnub"
  include ActionView::Helpers::NumberHelper
  # include ActionController::MimeResponds
  # require 'ruby-graphviz'
    #protect_from_forgery with: :null_session for api
    def request_status(sender,recipient)
      friend_request = FriendRequest.where(user_id: sender.id).where(friend_id: recipient.id).first
      if friend_request
       if friend_request.status == 'pending' || friend_request.status == 'accepted'
        status = {
          "message" => "You have already sent friend request to #{User.get_full_name(recipient)} ",
           "status" => true
         }
       end
      elsif FriendRequest.where(user_id: recipient.id).where(friend_id: sender.id).first
        status = {
           "message" => "#{User.get_full_name(recipient)} already sent you a friend request ",
           "status" => true
         }
        else
          status = {
            "message" => "",
            "status" => false
          }
      end
      status
  end

  def request_user
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    if token
     @decoded = decode(token)
     @current_user = User.find(@decoded[:user_id])
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

  def generate_uuid
    uuid = SecureRandom.uuid
  end

  def generate_six_digit_code
    code = rand(100 ** 3)
  end

  def generate_four_digit_code
    code = rand(100 ** 2)
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


  def is_removed_ticket?(request_user, ticket)
    setting = request_user.remove_tickets.where(resource: ticket).first
    removed = false
    removed = setting.is_on if setting
    removed
  end


  def is_followed(user)
    if request_user
     request_user.followings.include? user
    else
     false
    end
   end

   def is_friend?(request_user,friend)
    friend_request = request_user.friend_requests.where(friend_id: friend.id).where(status: 'accepted').first
    if friend_request
      true
    else
      false
    end
  end


  def string_to_hash(string)
    eval(string)
  end

   def get_dummy_avatar
     'https://pickaface.net/gallery/avatar/45425654_200117_1657_v2hx2.png'
   end



  def string_to_sym(string)
    string.parameterize.underscore.to_sym
  end

  def string_to_array_of_integers(string, delimeter)
    string.split(delimeter).map {|s| s.to_i }
  end
  

  def string_to_object_name(string)
   name = Object.const_get(string)
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
      "address" => eval(user.business_profile.address),
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
      "mutual_friends_count" => 0,
      "total_followers_count" => user.followers.size
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
      "location" => eval(user.profile.location),
      "lat" => user.profile.lat,
      "lng" => user.profile.lng,
      "device_token" => user.device_token,
      "ranking" => user.profile.ranking,
      "gender" => user.profile.gender,
      "dob" => user.profile.dob.to_date,
      "is_request_sent" => request_status(request_user, user)['status'],
      "role" => 5,
      "is_my_following" => false,
      "is_my_friend" => is_my_friend?(user),
      "mutual_friends_count" => get_mutual_friends(request_user, user).size,
      "location_enabled" => user.location_enabled
    }

  end

  def get_business_simple_object(user)
    object = {
      "id" => user.id,
      "profile_name" => user.business_profile.profile_name,
      "avatar" => user.avatar,
      "phone_number" => user.phone_number,
      "email" => user.email,
      "app_user" => user.app_user
    }
  end


  def get_user_simple_object(user)
    object = {
      "id" => user.id,
      "first_name" => user.profile.first_name,
      "last_name" => user.profile.last_name,
      "avatar" => user.avatar,
      "phone_number" => user.phone_number,
      "email" => user.email,
      "app_user" => user.app_user
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
      "status" => event.status,
      "event_forwarding" => event.event_forwarding,
      "over_18" => event.over_18,
      "image" => event.image,
      "description" => event.description,
      "terms_conditions" => event.terms_conditions,
      "categories" => event.categories,
      "location" => eval(event.location),
      "admission_resources" => admission_resources,
      "event_attachments" => event.event_attachments,
      "sponsors" => event.sponsors,
      "quantity" => event.quantity,
      "price_type" => event.price_type,
      "frequency" => event.frequency,
      "max_attendees" => event.max_attendees,
      "event_dates" => event.child_events.map {|ch| 
        {
          id: ch.id,
          start_date: ch.start_date.to_date,
          end_date: ch.end_date.to_date
        }

      }
    }
  end

  def get_pass_object(pass)
    object = {
      id: pass.id,
      title: pass.title,
      host_name: get_full_name(pass.event.user),
      host_image: pass.event.user.avatar,
      event_name: pass.event.name,
      event_image: pass.event.image,
      event_location: eval(pass.event.location),
      event_start_time: pass.event.start_time,
      event_end_time: pass.event.end_time,
      event_date: pass.event.start_date,
      distributed_by: distributed_by(pass),
      is_added_to_wallet: is_added_to_wallet?(pass.id),
      validity: pass.validity.strftime(get_time_format).to_s,
      grabbers_count: pass.wallets.size,
      terms_and_conditions: pass.terms_conditions,
      redeem_count: get_redeem_count(pass),
      quantity: pass.quantity
    }
  end


  def get_special_offer_object(offer)
    object = {
      id: offer.id,
      title: offer.title,
      sub_title: offer.sub_title,
      location: eval(offer.location),
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
      grabbers_friends_count: get_grabbers_friends_count(offer),
      issued_by: get_full_name(offer.user),
      redeem_count: get_redeem_count(offer),
      quantity: offer.quantity,
      terms_and_conditions: offer.terms_conditions
    }
  end


  def get_competition_object(competition)
    object = {
        id: competition.id,
        title: competition.title,
        description: competition.description,
        location: eval(competition.location),
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
        total_entries_count: get_entry_count(request_user, competition),
        issued_by: get_full_name(competition.user),
        is_followed: is_followed(competition.user),
        validity: competition.validity.strftime(get_time_format),
        terms_and_conditions: competition.terms_conditions
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
    @offers = []
    @businesses.each do |business|
      if !business.passes.blank?
      business.passes.not_expired.order(created_at: 'DESC').each do |pass|
        @offers << {
          id: pass.id,
          type: 'pass',
          title: pass.title,
          description: pass.description,
          host_name: get_full_name(business),
          host_image: business.avatar,
          event_name: pass.event.name,
          event_image: pass.event.image,
          event_location: eval(pass.event.location),
          event_start_time: pass.event.start_time,
          event_end_time: pass.event.end_time,
          event_date: pass.event.start_date,
          distributed_by: distributed_by(pass),
          is_added_to_wallet: is_added_to_wallet?(pass.id),
          validity: pass.validity.strftime(get_time_format).to_s,
          grabbers_count: pass.wallets.size,
          ambassador_stats: ambassador_stats(pass, request_user),
          ambassador_rate: pass.ambassador_rate,
          quantity: pass.quantity,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: pass.created_at,
          terms_and_conditions: pass.terms_conditions,
          redeem_count: get_redeem_count(pass),
          quantity: pass.quantity,
          issued_by: get_full_name(pass.user),
          business: get_business_object(business),
          distribution_count: pass.offer_shares.where(user: user).size + pass.offer_forwardings.where(user: user).size

        }
        end #each
      end #not empty

      if !business.special_offers.blank?
        business.special_offers.not_expired.order(created_at: 'DESC').each do |offer|
        @offers << {
          id: offer.id,
          type: 'special_offer',
          title: offer.title,
          sub_title: offer.sub_title,
          location: eval(offer.location),
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
          issued_by: get_full_name(offer.user),
          redeem_count: get_redeem_count(offer),
          quantity: offer.quantity,
          terms_and_conditions: offer.terms_conditions,
          business: get_business_object(business),
          distribution_count: offer.offer_shares.where(user: user).size + offer.offer_forwardings.where(user: user).size
        }
        end #each
      end #not empty
    end #each
 
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

  def is_added_to_wallet?(competition_id)
    if request_user
    wallet = request_user.wallets.where(offer_id: competition_id).where(offer_type: 'Competition')
    if !wallet.blank?
      true
    else
      false
    end
  else
     false
  end
  end



  def string_to_DateTime(string)
    DateTime.parse(string)
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


   def is_entered_competition_updated?(user, competition_id)
    if user
     reg = Registration.where(user_id: user).where(event_id: competition_id).where(event_type: 'Competition')
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
      request_user.events_to_attend.include? event
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
    user != request_user && user.phone_number != request_user.phone_number
   end


 def distributed_by(pass)
    distributed_by = 'n/a'
    if !pass.offer_forwardings.blank?
        user = pass.offer_forwardings.first.user
        if user && user.profile.is_ambassador == true
          distributed_by = get_full_name(user)
        end
    end
    distributed_by
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
     ##
  end

  def get_entry_count(user, competition)
    count = competition.registrations.where(user: user).size
  end

  def is_host?(user, resource)
    resource.user == user
  end


  def get_mutual_friends(request_user, user)
    user_friends = user.friends
    request_user_friends = request_user.friends
    mutual = user_friends & request_user_friends
  end


  def showability?(user, competition)
    if is_entered_competition_updated?(user, competition.id)
       reg = competition.registrations.where(user: user).last
        Time.now > reg.created_at + 24.hours
    else
     true
    end
   end

   def get_redeem_count(resource)
     resource.redemptions.size
   end



   def get_token_from_user(user)
    token = encode(user_id: user.id)
   end


   def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:remote_ip] = request.remote_ip
    payload[:ip] = request.ip
    payload[:x_forwarded_for] = request.env['HTTP_X_FORWARDED_FOR']
  end



  def get_price(event)
    price = ''
    if !event.tickets.where(ticket_type: 'buy').blank? && event.tickets.size > 1
       price = event.tickets.map {|ticket| ticket.price }
       price =  '€' + price.min + ' - ' + '€' + price.max
    elsif !event.tickets.where(ticket_type: 'buy').blank? && event.tickets.size == 1
       price = '€' + event.ticket.price
    elsif !event.tickets.where(ticket_type: 'pay_at_door').blank?
       price = '€' + event.tickets.first.start_price.to_s +  ' - €' + event.tickets.first.end_price.to_s
    else
      price = '0'
   end
   price
 end


 def approve_ambassador(user, ambassador_request_id)
   request = AmbassadorRequest.find(ambassador_request_id)
   request.status = 'accepted'
   profile =  request.user.profile
   profile.is_ambassador = true

   if request.save && profile.save
     #send notifcition to ambassador in order to inform
     @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
      )
    if notification = Notification.create!(recipient: request.user, actor: user, action: get_full_name(user) + " has approved you as an ambassador.", notifiable: request, url: "/admin/users/#{request.user.id}", resource: request, notification_type: 'mobile',action_type: 'become_ambassador')

      @current_push_token = @pubnub.add_channels_to_push(
        push_token: request.user.device_token,
        type: 'gcm',
        add: request.user.device_token
        ).value

        payload = {
          "pn_gcm":{
            "notification": {
              "title": get_full_name(user),
              "body": notification.action
            },
            data: {
              "id": notification.id,
              "business_name": User.get_full_name(notification.resource.business),
              "actor_image": notification.actor.avatar,
              "notifiable_id": notification.notifiable_id,
              "notifiable_type": notification.notifiable_type,
              "action": notification.action,
              "action_type": notification.action_type,
              "created_at": notification.created_at,
              "is_read": !notification.read_at.nil?,
              "location": location
            }
          }
        }

        @pubnub.publish(
          channel: [request.user.device_token],
          message: payload
           ) do |envelope|
             puts envelope.status
         end

         @success = true
        else
          @success = false
      end ##notification create

        if !request.user.friends.blank?
          request.user.friends.each do |friend|
            if notification = Notification.create(recipient: friend, actor: request.user, action: get_full_name(request.user) + " has become ambassador of #{User.get_full_name(request.business)}", notifiable: request, resource: request,  url: "/admin/users/#{request.user.id}", notification_type: 'mobile', action_type: "friend_become_ambassador")
            @push_channel = "event" #encrypt later
            @current_push_token = @pubnub.add_channels_to_push(
               push_token: friend.device_token,
               type: 'gcm',
               add: friend.device_token
               ).value

             payload = {
              "pn_gcm":{
               "notification":{
                 "title": User.get_full_name(request.user),
                 "body": notification.action
               },
               data: {
                "id": notification.id,
                "friend_name": User.get_full_name(notification.resource.user),
                "friend_id": notification.resource.user.id,
                "business_name": User.get_full_name(notification.resource.business),
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?,
                "location": location

               }
              }
             }
             @pubnub.publish(
              channel: friend.device_token,
              message: payload
              ) do |envelope|
                  puts envelope.status
             end
          end ##notification create
        end #each
      end #if not blank

      create_activity(request.user, "become ambassador ", request, 'AmbassadorRequest', '', '', 'post', 'become_ambassador')
    true
   else
    false
   end
 end


 def is_boolean?(variable)
  !!variable == variable
 end


 def get_max_price(event)
  price = ''
  if !event.tickets.where(ticket_type: 'buy').blank? && event.tickets.size > 1
     price = event.tickets.map {|ticket| ticket.price }
     price = price.max
  elsif !event.tickets.where(ticket_type: 'buy').blank? && event.tickets.size == 1
     price = event.tickets.first.price
  elsif !event.tickets.where(ticket_type: 'pay_at_door').blank?
     price = event.tickets.map {|ticket| ticket.end_price }
     price = price.max
  else
    price = '0'
 end
 price
end

      def get_demographics(event)
        males = []
        females = []
        gays = []
        demographics = {}
        total_count = event.going_interest_levels.size
        event.going_interest_levels.each do |level|
         case level.user.profile.gender
           when 'male'
             males.push(level.user)
           when 'female'
             females.push(level.user)
           when 'other'
             gays.push(level.user)
           else
              'No users'
            end
         end #each
  
         if males.size > 0 
            percentage = males.uniq.size.to_f / total_count.to_f * 100.0 
            males_percentage = percentage.round(2)
          else 
            males_percentage = 0 
          end
  
         if females.size > 0  
            percentage = females.uniq.size.to_f / total_count.to_f * 100.0
            female_percentage = percentage.round(2)  
          else
            female_percentage = 0 
           end
  
          if gays.size > 0 
             percentage = gays.uniq.size.to_f / total_count.to_f * 100.0  
             gays_percentage = percentage.round(2) 
            else
             gays_percentage = 0 
            end
  
          demographics['males_percentage'] = males_percentage
  
          demographics['females_percentage'] = female_percentage
  
          demographics['gays_percentage'] = gays_percentage
  
          demographics
     end


  def get_price_type(event)
    price_type = ''
    if !event.tickets.blank?
      price_type = event.tickets.first.ticket_type
    else
      price_type = 'no_admission_resources'
    end
     price_type
  end

  def has_passes?(event)
    !event.passes.blank?
  end


  def paginate_array(array)
    Kaminari.paginate_array(array)
  end

  def array_sort_by_date(array)
    array.sort_by { |h| h["start_date"].split('/').reverse }
  end

  def string_to_boolean(str)
    ActiveModel::Type::Boolean.new.cast(str)
  end

  def trim_space(string)
    string.gsub(' ', '')
  end


  def valid_date?(dt)
    begin
      Date.parse(dt)
      true
    rescue => e
      false
    end
  end


  def generate_date_range(first, last)
    first, last = "", first unless last
    if last.nil? || last.empty?
      last = (Time.now - 1.day).in_time_zone('Kolkata').strftime("%Y-%m-%d")
    end
    if first.empty?
      first = Time.strptime(last, "%Y-%m-%d").beginning_of_month.strftime("%Y-%m-%d")
    end
    (first..last).select { |d|  valid_date?(d) }
  end



  def insert_space_after_comma(string)
    string.gsub(/,(?![ ])/, ', ')
  end

  def to_underscore_case(string)
      string.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

def validate_event_dates(start_date, end_date, dates=[])
    dates_array = generate_date_range(start_date, end_date)
    (dates & dates_array) == dates
end

def all_passes_added_to_wallet?(request_user,passes)
    passes_ids = passes.map {|pass| pass.id }
    added_passes_ids = request_user.wallets.where(offer_type: 'Pass').where(offer_id: passes_ids).map {|w| w.offer.id }
    passes_ids.size == added_passes_ids.size
end


def get_mime_type(filename)
  mime_type = Rack::Mime.mime_type(File.extname(filename))
end


def friend_request_sent?(request_user, user)
  request_status(request_user, user)['status']
end


def mute_push_notification?(user)
   user.all_chat_notifications_setting.blank? && user.all_chat_notifications_setting.is_on 
end

def mute_event_notifications?(user, event)
    event_chat_muted?(user, event) && user.event_notifications_setting.blank? && user.event_notifications_setting.is_on
end

def get_percent_of(number, total)
  number.to_f / total.to_f * 100.0
end

  helper_method :SetJsVariables
  helper_method :is_admin_or_super_admin?
  helper_method :create_activity
  helper_method :generate_code
  helper_method :get_full_name
  helper_method :get_price



end
