class Api::V1::WalletsController < Api::V1::ApiMasterController
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

 def get_wallet
  @wallets = request_user.wallets.order(created_at: 'DESC')
  @wallet_data = {}
  @special_offers = []
  @passes = []
  @others = []
  @wallets.each do |wallet|
    case wallet.offer_type
      when 'SpecialOffer'
        @special_offers << {
        id: wallet.offer.id,
        title: wallet.offer.title,
        sub_title:wallet.offer.sub_title,
        location: wallet.offer.location,
        date: wallet.offer.date,
        time: wallet.offer.time,
        lat: wallet.offer.lat,
        lng: wallet.offer.lng,
        image: wallet.offer.image.url,
        creator_name: get_full_name(wallet.offer.user),
        creator_image: wallet.offer.user.avatar,
        description: wallet.offer.description,
        validity: wallet.offer.validity,
        is_expired: is_expired?(wallet.offer),
        grabbers_count: wallet.offer.wallets.size,
        is_redeemed: is_redeemed(wallet.offer.id, 'SpecialOffer', request_user.id),
        grabbers_friends_count: wallet.offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size
      }
     when 'Pass' 
      @passes << {
        id: wallet.offer.id,
        title: wallet.offer.title,
        host_name: get_full_name(wallet.offer.event.user),
        host_image: wallet.offer.event.user.avatar,
        event_name: wallet.offer.event.name,
        event_id: wallet.offer.event.id,
        event_image: wallet.offer.event.image,
        event_location: wallet.offer.event.location,
        event_start_time: wallet.offer.event.start_time,
        event_end_time: wallet.offer.event.end_time,
        event_date: wallet.offer.event.start_date,
        distributed_by: distributed_by(wallet.offer),
        validity: wallet.offer.validity,
        is_expired: is_expired?(wallet.offer),
        grabbers_count: wallet.offer.wallets.size,
        is_redeemed: is_redeemed(wallet.offer.id, 'Pass', request_user.id),
        grabbers_friends_count: wallet.offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size
      }
     else
      @others << {
        id: wallet.offer.id,
        title: wallet.offer.title,
        host_name: get_full_name(wallet.offer.event.user),
        host_image: wallet.offer.event.user.avatar,
        event_name: wallet.offer.event.name,
        event_id: wallet.offer.event.id,
        event_image: wallet.offer.event.image,
        event_location: wallet.offer.event.location,
        event_start_time: wallet.offer.event.start_time,
        event_end_time: wallet.offer.event.end_time,
        event_date: wallet.offer.event.start_date,
        price: wallet.offer.price,
        quantity: wallet.offer.quantity,
        purchased_quantity: getPurchaseQuantity(wallet.offer.id),
        per_head: wallet.offer.per_head,
        is_redeemed: is_redeemed(wallet.offer.id, "Ticket", request_user.id)
      } 
      end 
  end #each
  @wallet_data['special_offers'] = @special_offers
  @wallet_data['passes'] = @passes
  @wallet_data['others'] = @others

  render json: {
    code: 200,
    success: true,
    message: '',
    data: {
      wallet: @wallet_data
    }
  }
 end

 def add_to_wallet
  if !params[:offer_id].blank? && !params[:offer_type].blank?
    check  = request_user.wallets.where(offer_id: params[:offer_id]).where(offer_type: params[:offer_type]).first
    if check == nil
    @wallet  = request_user.wallets.new(offer_id: params[:offer_id], offer_type: params[:offer_type])
    if @wallet.save
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      if @notification = Notification.create(recipient: @wallet.offer.user, actor: request_user, action: get_full_name(request_user) + " added your offer '#{@wallet.offer.title}' to wallet.", notifiable: @wallet.offer, url: "/admin/#{ if @wallet.offer_type == 'Pass' then 'passes' else 'special_offers' end }/#{@wallet.offer.id}", notification_type: 'web', action_type: 'add_to_wallet')  
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
            if @notification = Notification.create(recipient: friend, actor: request_user, action: get_full_name(request_user) + " has grabbed #{@wallet.offer.class.name.downcase} '#{@wallet.offer.title}'.", notifiable: @wallet.offer, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet') 
            @push_channel = "event" #encrypt later
            @current_push_token = @pubnub.add_channels_to_push(
               push_token: friend.profile.device_token,
               type: 'gcm',
               add: friend.profile.device_token
               ).value
    
             payload = { 
              "pn_gcm":{
               "notification":{
                 "title": @wallet.offer.title,
                 "body": @notification.action
               },
               data: {
                "id": @notification.id,
                "actor_id": @notification.actor_id,
                "actor_image": @notification.actor.avatar,
                "notifiable_id": @notification.notifiable_id,
                "notifiable_type": @notification.notifiable_type,
                "action": @notification.action,
                "action_type": @notification.action_type,
                "created_at": @notification.created_at,
                "body": ''   
               }
              }
             }
             @pubnub.publish(
              channel: friend.profile.device_token,
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

 def view_offer
  if !params[:offer_id].blank? && !params[:offer_type].blank?
    @offer_array = []
   if params[:offer_type] == "Pass"
    pass = Pass.find(params[:offer_id])
    @offer_array << {
      id: pass.id,
      title: pass.title,
      host_name: get_full_name(pass.user),
      host_image: pass.user.avatar,
      event_name: pass.event.name,
      event_image:pass.event.image,
      event_location: pass.event.location,
      event_start_time: pass.event.start_time,
      event_end_time: pass.event.end_time,
      event_date: pass.event.start_date,
      distributed_by: distributed_by(pass),
      is_added_to_wallet: is_added_to_wallet?(pass.id),
      validity: pass.validity,
      is_expired: is_expired?(pass),
      grabbers_count: pass.wallets.size
    } 
   elsif(params[:offer_type] == 'SpecialOffer')
    offer = SpecialOffer.find(params[:offer_id])
    @offer_array << {
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
      validity: offer.validity,
      end_time: offer.end_time, 
      is_expired: is_expired?(offer),
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size
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

def getPurchaseQuantity(ticket_id)
  TicketPurchase.where(user_id: request_user.id).where(ticket_id: ticket_id).first.quantity
end

end
