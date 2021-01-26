class Api::V1::WalletsController < Api::V1::ApiMasterController
  before_action :authorize_request
  before_action
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

api :GET, '/api/v1/wallet/get-offers', 'Get wallet special offers'

 def get_offers
    @redeemed_offers = []
    @unredeemed_offers = []
    @sorted_offers = []
    @expired_offers = []

    offer_ids = request_user.wallets.where(offer_type: 'SpecialOffer').where(is_removed: false).page(params[:page]).per(get_per_page).map {|w| w.offer.id }

    sort_by_date_offers = SpecialOffer.where(id: offer_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|offer| @sorted_offers.push(offer) }

    sort_by_redemption_offers = request_user.redemptions.sort_by_date.where(offer_type: 'SpecialOffer').page(params[:page]).per(get_per_page).map {|redemption| @sorted_offers.push(redemption.offer) }

    @sorted_offers.uniq.each do |offer|
      if is_redeemed(offer.id, 'SpecialOffer', request_user.id)

       @redeemed_offers << {

        id: offer.id,
        title: offer.title,
        description: offer.description,
        sub_title: offer.sub_title,
        location: eval(offer.location),
        date: offer.date,
        time: offer.time,
        lat: offer.lat,
        lng: offer.lng,
        image: offer.image.url,
        is_redeemed: true,
        creator_name: get_full_name(offer.user),
        creator_image: offer.user.avatar,
        validity: offer.validity.strftime(get_time_format),
        is_expired: is_expired?(offer),
        grabbers_count: offer.wallets.size,
        is_redeemed: is_redeemed(offer.id, 'SpecialOffer', request_user.id),
        redeem_time: redeem_time(offer.id, 'SpecialOffer', request_user.id),
        grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
        terms_and_conditions: offer.terms_conditions,
        issued_by: get_full_name(offer.user),
        redeem_count: get_redeem_count(offer),
        quantity: offer.quantity

       }

      elsif  is_expired?(offer)
        @expired_offers << {
        id: offer.id,
        title: offer.title,
        description: offer.description,
        sub_title: offer.sub_title,
        location: eval(offer.location),
        date: offer.date,
        time: offer.time,
        lat: offer.lat,
        lng: offer.lng,
        image: offer.image.url,
        creator_name: get_full_name(offer.user),
        creator_image: offer.user.avatar,
        validity: offer.validity.strftime(get_time_format),
        is_expired: is_expired?(offer),
        grabbers_count: offer.wallets.size,
        is_redeemed: is_redeemed(offer.id, 'SpecialOffer', request_user.id),
        redeem_time: redeem_time(offer.id, 'SpecialOffer', request_user.id),
        grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
        terms_and_conditions: offer.terms_conditions,
        issued_by: get_full_name(offer.user),
        redeem_count: get_redeem_count(offer),
        quantity: offer.quantity
      }
      else
       @unredeemed_offers << {
        id: offer.id,
        title: offer.title,
        description: offer.description,
        sub_title: offer.sub_title,
        location: eval(offer.location),
        date: offer.date,
        time: offer.time,
        lat: offer.lat,
        lng: offer.lng,
        image: offer.image.url,
        is_redeemed: false,
        creator_name: get_full_name(offer.user),
        creator_image: offer.user.avatar,
        validity: offer.validity.strftime(get_time_format),
        is_expired: is_expired?(offer),
        grabbers_count: offer.wallets.size,
        is_redeemed: is_redeemed(offer.id, 'SpecialOffer', request_user.id),
        redeem_time: redeem_time(offer.id, 'SpecialOffer', request_user.id),
        grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
        terms_and_conditions: offer.terms_conditions,
        issued_by: get_full_name(offer.user),
        redeem_count: get_redeem_count(offer),
        quantity: offer.quantity


       }
      end #if
      end #each


      @final_sorted = custom_sort(@unredeemed_offers, @redeemed_offers)

      @expired_offers.map {|e_offer| @final_sorted << e_offer }

      render json:  {
       code: 200,
       success: true,
       message: '',
       data: {
         special_offers: @final_sorted }
     }

 end

  api :GET, '/api/v1/wallet/get-passes', 'Get Wallet Passes'

 def get_passes
  @redeemed_passes = []
  @unredeemed_passes = []
  @sorted_passes = []
  @expired_passes = []
   pass_ids = request_user.wallets.where(offer_type: 'Pass').where(is_removed: false).page(params[:page]).per(get_per_page).map {|w| w.offer.id }

   sort_by_date_passes = Pass.where(id: pass_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|pass| @sorted_passes.push(pass) }

   sort_by_redemption_passes = request_user.redemptions.sort_by_date.where(offer_type: 'Pass').page(params[:page]).per(get_per_page).map {|redemption| @sorted_passes.push(redemption.offer) }

@sorted_passes.uniq.each do |pass|
 if is_redeemed(pass.id, 'Pass', request_user.id)

          @redeemed_passes << {
            id: pass.id,
            title: pass.title,
            description: pass.description,
            host_name: get_full_name(pass.event.user),
            host_image: pass.event.user.avatar,
            event_name: pass.event.name,
            event_id: pass.event.id,
            event_image: pass.event.image,
            event_location: eval(pass.event.location),  
            event_start_time: get_date_time(pass.event.start_date, pass.event.start_time),
            event_end_time: get_date_time(pass.event.end_date, pass.event.end_time),
            event_date: pass.event.start_date,
            distributed_by: distributed_by(pass),
            validity: pass.valid_to.strftime(get_time_format),
            is_expired: is_expired?(pass),
            grabbers_count: pass.wallets.size,
            is_redeemed: true,
            redeem_time: redeem_time(pass.id, 'Pass', request_user.id),
            grabbers_friends_count: pass.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
            terms_and_conditions: pass.terms_conditions,
            redeem_count: get_redeem_count(pass),
            quantity: pass.quantity,
            issued_by: get_full_name(pass.user),
            pass_type: pass.pass_type

          }

        elsif  is_expired?(pass)
            @expired_passes << {
            id: pass.id,
            title: pass.title,
            description: pass.description,
            host_name: get_full_name(pass.event.user),
            host_image: pass.event.user.avatar,
            event_name: pass.event.name,
            event_id: pass.event.id,
            event_image: pass.event.image,
            pass_type: pass.pass_type,
            event_location: eval(pass.event.location),
            event_start_time: get_date_time(pass.event.start_date, pass.event.start_time),
            event_end_time: get_date_time(pass.event.end_date, pass.event.end_time),
            event_start_date: pass.event.start_date,
            distributed_by: distributed_by(pass),
            validity: pass.valid_to.strftime(get_time_format),
            is_expired: is_expired?(pass),
            grabbers_count: pass.wallets.size,
            is_redeemed: false,
            redeem_time: redeem_time(pass.id, 'Pass', request_user.id),
            grabbers_friends_count: pass.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
            terms_and_conditions: pass.terms_conditions,
            redeem_count: get_redeem_count(pass),
            quantity: pass.quantity,
            issued_by: get_full_name(pass.user),
            pass_type: pass.pass_type

          }
        else
          @unredeemed_passes << {
            id: pass.id,
            title: pass.title,
            host_name: get_full_name(pass.event.user),
            host_image: pass.event.user.avatar,
            event_name: pass.event.name,
            event_id: pass.event.id,
            event_image: pass.event.image,
            event_location: eval(pass.event.location),
            event_start_time: get_date_time(pass.event.start_date, pass.event.start_time),
            event_end_time: get_date_time(pass.event.end_date, pass.event.end_time),
            event_date: pass.event.start_date,
            distributed_by: distributed_by(pass),
            validity: pass.valid_to.strftime(get_time_format),
            is_expired: is_expired?(pass),
            grabbers_count: pass.wallets.size,
            is_redeemed: false,
            redeem_time: redeem_time(pass.id, 'Pass', request_user.id),
            grabbers_friends_count: pass.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
            terms_and_conditions: pass.terms_conditions,
            redeem_count: get_redeem_count(pass),
            quantity: pass.quantity,
            issued_by: get_full_name(pass.user),
            pass_type: pass.pass_type

          }
         end #if
         end #each


         @final_sorted = custom_sort(@unredeemed_passes, @redeemed_passes)

         @expired_passes.map {|e_pass| @final_sorted << e_pass }

            render json:  {
             code: 200,
             success: true,
             message: '',
             data: {
               passes: @final_sorted }
           }

end





  api :GET, '/api/v1/wallet/get-competitions', 'Get wallet competitions'

def get_competitions
  @competitions = []
  @sorted_competitions = []
  @expired_competitions = []
  competition_ids = request_user.wallets.where(offer_type: 'Competition').where(is_removed: false).page(params[:page]).per(get_per_page).map {|w| w.offer.id }

  sort_by_date_competitions = Competition.where(id: competition_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|competition| @sorted_competitions.push(competition) }

  @sorted_competitions.uniq.each do |competition|
   if is_expired?(competition)
    @expired_competitions << {
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
      is_expired: is_expired?(competition),
      creator_image: competition.user.avatar,
      creator_id: competition.user.id,
      total_entries_count: get_entry_count(request_user, competition),
      issued_by: get_full_name(competition.user),
      is_followed: is_followed(competition.user),
      validity: competition.validity.strftime(get_time_format),
      terms_and_conditions: competition.terms_conditions
     }
    else
      @competitions << {
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
        is_expired: is_expired?(competition),
        creator_image: competition.user.avatar,
        creator_id: competition.user.id,
        total_entries_count: get_entry_count(request_user, competition),
        issued_by: get_full_name(competition.user),
        is_followed: is_followed(competition.user),
        validity: competition.validity.strftime(get_time_format),
        terms_and_conditions: competition.terms_conditions
       }
    end
  end#each

  #push at the end competition that are expired.
     if !@expired_competitions.blank?
      @expired_competitions.map {|ec| @competitions.push(ec) }
     end

  render json:  {
    code: 200,
    success: true,
    message: '',
    data: {
      competitions: @competitions
    }
  }

end

  api :GET, '/api/v1/wallet/get-tickets', 'Get Wallet tickets'

def get_tickets
  @tickets = []
  @wallets = request_user.wallets.where(offer_type: 'Ticket').where(is_removed: false).page(params[:page]).per(get_per_page)
  @wallets.each do |wallet|
  @tickets << {
    id: wallet.offer.id,
    title: wallet.offer.title,
    host_name: get_full_name(wallet.offer.event.user),
    host_image: wallet.offer.event.user.avatar,
    event_name: wallet.offer.event.name,
    event_description: wallet.offer.event.description,
    event_terms_conditions: wallet.offer.event.terms_conditions,
    going_count: wallet.offer.event.going_interest_levels.size,
    event_id: wallet.offer.event.id,
    event_image: wallet.offer.event.image,
    event_location: eval(wallet.offer.event.location),
    event_start_time: wallet.offer.event.start_time,
    event_end_time: wallet.offer.event.end_time,
    event_date: wallet.offer.event.start_date,
    price: get_formated_price(wallet.offer.price),
    quantity: wallet.offer.quantity,
    purchased_quantity: getPurchaseQuantity(wallet.offer.id, request_user),
    per_head: wallet.offer.per_head,
    is_redeemed: is_redeemed(wallet.offer.id, "Ticket", request_user.id),
    redeem_time: redeem_time(wallet.offer.id, "Ticket", request_user.id),
    validity: wallet.offer.event.end_date,
    is_expired: event_expired?(wallet.offer.event),

  }
end #each

render json:  {
    code: 200,
    success: true,
    message: '',
    data: {
      tickets: @tickets
    }
  }

end

  api :POST, '/api/v1/wallet/remove-follower', 'To remove an item from the wallet'
  param :offer_id, :number, :desc => "Offer ID - Item ID", :required => true
 # param :offer_type, String, :desc => "competitions/special_offers/tickets/pass", :required => true


def remove_offer
 all_is_well = !params[:offer_id].blank? && !params[:offer_type].blank?
 if all_is_well
    @wallet = request_user.wallets.where(offer_id: params[:offer_id]).where(offer_type: params[:offer_type]).first
    if @wallet.update!(is_removed: true)
      render json:  {
      code: 200,
      success: true,
      message: 'Item successfully removed.',
      data: nil
    }
    else
      render json:  {
        code: 400,
        success: false,
        message: @wallet.errors.full_messages,
        data: nil
      }
    end
 else

  render json: {
    code: 400,
    success: false,
    message: 'offer_id and offer_type is required field.',
    data: nil
  }
 end
end

  api :POST, '/api/v1/add-to-wallet', 'Add offers to your wallet'
  param :offer_id, :number, :desc => "Offer ID", :required => true
  #param :offer_type, ['pass', 'special offer'], :desc => "Offer Type (SpecialOffer, Pass)", :required => true



 def add_to_wallet
  if !params[:offer_id].blank? && !params[:offer_type].blank?
       quantity = 1
      if params[:offer_type] == "Ticket" && params[:quantity].blank? || params[:offer_type] == "Ticket" && params[:event_id].blank?
         render json: {
           code: 400,
           success: false,
           message: "quantity, event_id is required field.",
           data: nil
         }
        return
        else
          quantity = params[:quantity]
        end 
      
    check  = request_user.wallets.where(offer_id: params[:offer_id]).where(offer_type: params[:offer_type]).first
    if check == nil 
    @wallet  = request_user.wallets.new(offer_id: params[:offer_id], offer_type: params[:offer_type],quantity: quantity)
    if @wallet.save
       if params[:offer_type] == "Ticket"
          ticket = Ticket.find(params[:offer_id])
          child_event = ChildEvent.find(params[:event_id])
          # event = ticket.event
          # event.going_interest_levels.create!(user: request_user, child_event: child_event)
         level =  child_event.going_interest_levels.create!(user: request_user)
         purchase_ticket = request_user.ticket_purchases.create!(user: request_user, ticket_id: ticket.id, quantity: params[:quantity], price: 0)
              ticket.quantity = ticket.quantity - params[:quantity].to_i
              ticket.save
       
       end
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )

      if @notification = Notification.create(recipient: @wallet.offer.user, actor: request_user, action: get_full_name(request_user) + " added your offer '#{@wallet.offer.title}' to wallet.", notifiable: @wallet.offer, resource: @wallet, url: "/admin/#{ if @wallet.offer_type == 'Pass' then 'passes' else 'special_offers' end }/#{@wallet.offer.id}", notification_type: 'web', action_type: "add_#{@wallet.offer.class.name}_to_wallet")
        @pubnub.publish(
          channel: [@wallet.offer.user.id.to_s],
          message: {
            action: @notification.action,
            avatar: request_user.avatar,
            time: time_ago_in_words(@notification.created_at),
            notification_url: @notification.url
           }
        ) do |envelope|
          puts envelope.status
         end
       end ##notification create
        #also notify request_user friends
        if !request_user.friends.blank?
          request_user.friends.each do |friend|

            if notification = Notification.create(recipient: friend, actor: request_user, action: get_full_name(request_user) + " has grabbed #{@wallet.offer.class.name} '#{@wallet.offer.title}'.", notifiable: @wallet.offer, resource: @wallet,  url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: "add_#{@wallet.offer.class.name}_to_wallet")
            @push_channel = "event" #encrypt later
            @current_push_token = @pubnub.add_channels_to_push(
               push_token: friend.device_token,
               type: 'gcm',
               add: friend.device_token
               ).value


           case params[:offer_type]
              when "Competition"
                data =  {
                  "id": notification.id,
                  "friend_name": User.get_full_name(notification.resource.user),
                  "business_name": User.get_full_name(notification.resource.offer.user),
                  "competition_id": notification.resource.offer.id,
                  "competition_name": notification.resource.offer.title,
                  "competition_host": User.get_full_name(notification.resource.offer.user),
                  "competition_draw_date": notification.resource.offer.end_date,
                  "user_id": notification.resource.user.id,
                  "actor_image": notification.actor.avatar,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }

              when "Pass"
                data = {
                  "id": notification.id,
                  "friend_name": User.get_full_name(notification.resource.user),
                  "event_name": notification.resource.offer.event.name,
                  "event_start_date": notification.resource.offer.event.start_date,
                  "pass_id": notification.resource.offer.id,
                  "event_location": eval(notification.resource.offer.event.location),
                  "user_id": notification.resource.offer.user.id,
                  "actor_image": notification.actor.avatar,
                  "total_grabbers_count": notification.resource.offer.wallets.size,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }

              when "SpecialOffer"
                data = {
                  "id": notification.id,
                  "friend_name": User.get_full_name(notification.resource.user),
                  "special_offer_id": notification.resource.offer.id,
                  "special_offer_title": notification.resource.offer.title,
                  "business_name": User.get_full_name(notification.resource.offer.user),
                  "total_grabbers_count": notification.resource.offer.wallets.size,
                  "user_id": notification.resource.user.id,
                  "actor_image": notification.actor.avatar,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }

              else
                "do nothing"
              end

              payload = {
                "pn_gcm":{
                "notification":{
                  "title": @wallet.offer.title,
                  "body": notification.action
                },
                data: data
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
      create_activity(request_user, "added to wallet", @wallet.offer, params[:offer_type], '', @wallet.offer.title, 'post',"added_#{params[:offer_type]}_to_wallet")
      render json: {
        code: 200,
        success: true,
        message: 'Added to wallet successfully.',
        data: @wallet
      }
    else
      render json: {
        code: 400,
        success: false,
        message: @wallet.errors.full_messages,
        data: nil
      }
    end
  elsif params[:offer_type] == 'Ticket' && check.quantity < check.offer.quantity
    @wallet  = request_user.wallets.new(offer_id: params[:offer_id], offer_type: params[:offer_type],quantity: quantity)
  
    if @wallet.save
    
        ticket = Ticket.find(params[:offer_id])
        child_event = ChildEvent.find(params[:event_id])
        # event = ticket.event
        # event.going_interest_levels.create!(user: request_user, child_event: child_event)
        level =  child_event.going_interest_levels.create!(user: request_user)
  
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )

      if @notification = Notification.create(recipient: @wallet.offer.user, actor: request_user, action: get_full_name(request_user) + " added your offer '#{@wallet.offer.title}' to wallet.", notifiable: @wallet.offer, resource: @wallet, url: "/admin/#{ if @wallet.offer_type == 'Pass' then 'passes' else 'special_offers' end }/#{@wallet.offer.id}", notification_type: 'web', action_type: "add_#{@wallet.offer.class.name}_to_wallet")
        @pubnub.publish(
          channel: [@wallet.offer.user.id.to_s],
          message: {
            action: @notification.action,
            avatar: request_user.avatar,
            time: time_ago_in_words(@notification.created_at),
            notification_url: @notification.url
           }
        ) do |envelope|
          puts envelope.status
         end
       end ##notification create
        #also notify request_user friends
        if !request_user.friends.blank?
          request_user.friends.each do |friend|

            if notification = Notification.create(recipient: friend, actor: request_user, action: get_full_name(request_user) + " has grabbed #{@wallet.offer.class.name} '#{@wallet.offer.title}'.", notifiable: @wallet.offer, resource: @wallet,  url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: "add_#{@wallet.offer.class.name}_to_wallet")
            @push_channel = "event" #encrypt later
            @current_push_token = @pubnub.add_channels_to_push(
               push_token: friend.device_token,
               type: 'gcm',
               add: friend.device_token
               ).value


           case params[:offer_type]
              when "Competition"
                data =  {
                  "id": notification.id,
                  "friend_name": User.get_full_name(notification.resource.user),
                  "business_name": User.get_full_name(notification.resource.offer.user),
                  "competition_id": notification.resource.offer.id,
                  "competition_name": notification.resource.offer.title,
                  "competition_host": User.get_full_name(notification.resource.offer.user),
                  "competition_draw_date": notification.resource.offer.end_date,
                  "user_id": notification.resource.user.id,
                  "actor_image": notification.actor.avatar,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }

              when "Pass"
                data = {
                  "id": notification.id,
                  "friend_name": User.get_full_name(notification.resource.user),
                  "event_name": notification.resource.offer.event.name,
                  "event_start_date": notification.resource.offer.event.start_date,
                  "pass_id": notification.resource.offer.id,
                  "event_location": eval(notification.resource.offer.event.location),
                  "user_id": notification.resource.offer.user.id,
                  "actor_image": notification.actor.avatar,
                  "total_grabbers_count": notification.resource.offer.wallets.size,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }

              when "SpecialOffer"
                data = {
                  "id": notification.id,
                  "friend_name": User.get_full_name(notification.resource.user),
                  "special_offer_id": notification.resource.offer.id,
                  "special_offer_title": notification.resource.offer.title,
                  "business_name": User.get_full_name(notification.resource.offer.user),
                  "total_grabbers_count": notification.resource.offer.wallets.size,
                  "user_id": notification.resource.user.id,
                  "actor_image": notification.actor.avatar,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }

              else
                "do nothing"
              end

              payload = {
                "pn_gcm":{
                "notification":{
                  "title": @wallet.offer.title,
                  "body": notification.action
                },
                data: data
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
      create_activity(request_user, "added to wallet", @wallet.offer, params[:offer_type], '', @wallet.offer.title, 'post',"added_#{params[:offer_type]}_to_wallet")
      render json: {
        code: 200,
        success: true,
        message: 'Added to wallet successfully.',
        data: @wallet
      }
    else
      render json: {
        code: 400,
        success: false,
        message: @wallet.errors.full_messages,
        data: nil
      }
    end
  else
    render json:  {
      code: 400,
      success: false,
      message: "Offer is already added.",
      data: check
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: 'Offer id and offer type is requried.',
      data: nil
    }
  end
 end

  api :POST, '/api/v1/view-offer', 'View offer(special_offers, pass'
  param :offer_id, :number, :desc => "Offer ID", :required => true
  #param :offer_type, :number, :desc => "Offer Type(SpecialOffer, Pass)", :required => true


 def view_offer
  if !params[:offer_id].blank? && !params[:offer_type].blank?
    @offer_array = []
   if params[:offer_type] == "Pass"
    pass = Pass.find(params[:offer_id])
    @offer_array << {
      id: pass.id,
      title: pass.title,
      description: pass.description,
      host_name: get_full_name(pass.user),
      host_image: pass.user.avatar,
      event_name: pass.event.name,
      event_image:pass.event.image,
      event_location: eval(pass.event.location),
      event_start_time: pass.event.start_time,
      event_end_time: pass.event.end_time,
      event_date: pass.event.start_date,
      distributed_by: distributed_by(pass),
      is_added_to_wallet: is_added_to_wallet?(pass.id),
      validity: pass.validity.strftime(get_time_format),
      is_expired: is_expired?(pass),
      grabbers_count: pass.wallets.size,
      terms_and_conditions: pass.terms_conditions
    }
   elsif(params[:offer_type] == 'SpecialOffer')
    offer = SpecialOffer.find(params[:offer_id])
    @offer_array << {
      id: offer.id,
      title: offer.title,
      description: offer.description,
      sub_title: offer.sub_title,
      location: eval(offer.location),
      date: offer.date,
      time: offer.time,
      lat: offer.lat,
      lng: offer.lng,
      image: offer.image.url,
      creator_name: get_full_name(offer.user),
      creator_image: offer.user.avatar,
      validity: offer.validity.strftime(get_time_format),
      end_time: offer.end_time,
      is_expired: is_expired?(offer),
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
      terms_and_conditions: offer.terms_conditions
    }
   end

   render json: {
    code: 200,
    success: true,
    message: "",
    data: {
      offer: @offer_array
    }
  }



  else
    render json: {
      code: 400,
      success: false,
      message: "offer_id and offer_type are required fields.",
      data: nil
    }
  end
 end

 def remove_from_wallet
 end



 private

 def get_date_time(date, time)
    d = date.strftime("%Y-%m-%d")
    t = time.strftime("%H:%M:%S")
    datetime = d + "T" + t + ".000Z"
 end

 def is_added_to_wallet?(pass_id)
  wallet = request_user.wallets.where(offer_id: pass_id).where(offer_type: 'Pass')
  if !wallet.blank?
    true
  else
    false
  end
end

def is_redeemed(offer_id, offer_type,user_id)
  @check = Redemption.where(offer_id: offer_id).where(offer_type: offer_type).where(user_id: user_id)
  if !@check.blank?
     true
  else
    false
  end
end

def redeem_time(offer_id, offer_type,user_id)
  @check = Redemption.where(offer_id: offer_id).where(offer_type: offer_type).where(user_id: user_id)
  if !@check.blank?
     @check.first.created_at
  else
    ''
  end
end

def getPurchaseQuantity(ticket_id,user)
  purchase_quantity = 0
    if user
       purchases = TicketPurchase.where(user_id: request_user.id).where(ticket_id: ticket_id)
      purchase_quantity += purchases.map {|p| p.ticket.quantity }.sum
      purchase_quantity += user.wallets.where(offer_type: "Ticket").where(offer_id: ticket_id).size
     
    end
    purchase_quantity
end




def custom_sort(array, array2push2End)
  sorted = array - array2push2End + array2push2End
end


end
