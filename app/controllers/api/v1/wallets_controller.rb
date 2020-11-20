class Api::V1::WalletsController < Api::V1::ApiMasterController
  before_action :authorize_request
  before_action
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

 def get_wallet

  @wallet_data = {}
  @special_offers = []
  @passes = []
  @tickets = []
  @competitions = []
  @wallets.each do |wallet|
    case wallet.offer_type
      when 'SpecialOffer'
        @special_offers << {
        id: wallet.offer.id,
        title: wallet.offer.title,
        description: wallet.offer.description,
        sub_title:wallet.offer.sub_title,
        location: wallet.offer.location,
        date: wallet.offer.date,
        time: wallet.offer.time,
        lat: wallet.offer.lat,
        lng: wallet.offer.lng,
        image: wallet.offer.image.url,
        creator_name: get_full_name(wallet.offer.user),
        creator_image: wallet.offer.user.avatar,
        validity: wallet.offer.validity.strftime(get_time_format),
        is_expired: is_expired?(wallet.offer),
        grabbers_count: wallet.offer.wallets.size,
        is_redeemed: is_redeemed(wallet.offer.id, 'SpecialOffer', request_user.id),
        grabbers_friends_count: wallet.offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
        terms_and_conditions: wallet.offer.terms_conditions,
        issued_by: get_full_name(wallet.offer.user),
        redeem_count: get_redeem_count(wallet.offer),
        quantity: wallet.offer.quantity
      }
     when 'Pass'
      @passes << {
        id: wallet.offer.id,
        title: wallet.offer.title,
        description: wallet.offer.description,
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
        validity: wallet.offer.validity.strftime(get_time_format),
        is_expired: is_expired?(wallet.offer),
        grabbers_count: wallet.offer.wallets.size,
        is_redeemed: is_redeemed(wallet.offer.id, 'Pass', request_user.id),
        grabbers_friends_count: wallet.offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
        terms_and_conditions: wallet.offer.terms_conditions,
        redeem_count: get_redeem_count(wallet.offer),
        quantity: wallet.offer.quantity,
        issued_by: get_full_name(wallet.offer.user)
      }
    when 'Ticket'
      @tickets << {
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
        price: get_formated_price(wallet.offer.price),
        quantity: wallet.offer.quantity,
        purchased_quantity: getPurchaseQuantity(wallet.offer.id),
        per_head: wallet.offer.per_head,
        is_redeemed: is_redeemed(wallet.offer.id, "Ticket", request_user.id)

      }
    when 'Competition'
      @competitions << {
        id: wallet.offer.id,
        title: wallet.offer.title,
        description: wallet.offer.description,
        location: wallet.offer.location,
        start_date: wallet.offer.start_date,
        end_date: wallet.offer.end_date,
        start_time: wallet.offer.start_time,
        end_time: wallet.offer.end_time,
        price: wallet.offer.price,
        lat: wallet.offer.lat,
        lng: wallet.offer.lng,
        image: wallet.offer.image.url,
        is_entered: is_entered_competition?(wallet.offer.id),
        participants_stats: get_participants_stats(wallet.offer),
        creator_name: wallet.offer.user.business_profile.profile_name,
        creator_image: wallet.offer.user.avatar,
        creator_id: wallet.offer.user.id,
        total_entries_count: get_entry_count(request_user, wallet.offer),
        issued_by: get_full_name(wallet.offer.user),
        is_followed: is_followed(wallet.offer.user),
        validity: wallet.offer.validity.strftime(get_time_format),
        terms_and_conditions: wallet.offer.terms_conditions
       }
    else
       'do nothing'
    end #case
  end #each
  @wallet_data['special_offers'] = @special_offers
  @wallet_data['passes'] = @passes
  @wallet_data['tickets'] = @tickets
  @wallet_data['competitions'] = @competitions

  render json: {
    code: 200,
    success: true,
    message: '',
    data: {
      wallet: @wallet_data
    }
  }
 end


 def get_offers
  @special_offers = []
  @wallets = request_user.wallets.where(offer_type: 'SpecialOffer').where(is_removed: false).page(params[:page]).per(get_per_page)
  @wallets.each do |wallet|
        @special_offers << {
        id: wallet.offer.id,
        title: wallet.offer.title,
        description: wallet.offer.description,
        sub_title:wallet.offer.sub_title,
        location: wallet.offer.location,
        date: wallet.offer.date,
        time: wallet.offer.time,
        lat: wallet.offer.lat,
        lng: wallet.offer.lng,
        image: wallet.offer.image.url,
        creator_name: get_full_name(wallet.offer.user),
        creator_image: wallet.offer.user.avatar,
        validity: wallet.offer.validity.strftime(get_time_format),
        is_expired: is_expired?(wallet.offer),
        grabbers_count: wallet.offer.wallets.size,
        is_redeemed: is_redeemed(wallet.offer.id, 'SpecialOffer', request_user.id),
        redeem_time: redeem_time(wallet.offer.id, 'SpecialOffer', request_user.id),
        grabbers_friends_count: wallet.offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
        terms_and_conditions: wallet.offer.terms_conditions,
        issued_by: get_full_name(wallet.offer.user),
        redeem_count: get_redeem_count(wallet.offer),
        quantity: wallet.offer.quantity
      }
    end#foreach

    render json:  {
       code: 200,
       success: true,
       message: '',
       data: {
         special_offers: @special_offers
       }
    }
 end


 def get_passes
  @redeemed_passes = []
  @unredeemed_passes = []
  @sorted_passes = []
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

    event_location: pass.event.location,

    event_start_time: pass.event.start_time,

    event_end_time: pass.event.end_time,

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

    issued_by: get_full_name(pass.user)

  }
else
  @unredeemed_passes << {
    id: pass.id,

    title: pass.title,

    description: pass.description,

    host_name: get_full_name(pass.event.user),

    host_image: pass.event.user.avatar,

    event_name: pass.event.name,

    event_id: pass.event.id,

    event_image: pass.event.image,

    event_location: pass.event.location,

    event_start_time: pass.event.start_time,

    event_end_time: pass.event.end_time,

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

    issued_by: get_full_name(pass.user)

  }
 end #if
 end #each

 @final_sorted = custom_sort(@unredeemed_passes, @redeemed_passes)

 render json:  {
  code: 200,
  success: true,
  message: '',
  data: {
    passes: @final_sorted,
    user: request_user
  }
}
 end


def get_competitions
  @competitions = []
  @wallets = request_user.wallets.where(offer_type: 'Competition').where(is_removed: false).page(params[:page]).per(get_per_page)
  @wallets.each do |wallet|
    @competitions << {
      id: wallet.offer.id,
      title: wallet.offer.title,
      description: wallet.offer.description,
      location: wallet.offer.location,
      start_date: wallet.offer.start_date,
      end_date: wallet.offer.end_date,
      start_time: wallet.offer.start_time,
      end_time: wallet.offer.end_time,
      price: wallet.offer.price,
      lat: wallet.offer.lat,
      lng: wallet.offer.lng,
      image: wallet.offer.image.url,
      is_entered: is_entered_competition?(wallet.offer.id),
      participants_stats: get_participants_stats(wallet.offer),
      creator_name: wallet.offer.user.business_profile.profile_name,
      is_expired: is_expired?(wallet.offer),
      creator_image: wallet.offer.user.avatar,
      creator_id: wallet.offer.user.id,
      total_entries_count: get_entry_count(request_user, wallet.offer),
      issued_by: get_full_name(wallet.offer.user),
      is_followed: is_followed(wallet.offer.user),
      validity: wallet.offer.validity.strftime(get_time_format),
      terms_and_conditions: wallet.offer.terms_conditions
     }
  end#each

  render json:  {
    code: 200,
    success: true,
    message: '',
    data: {
      competitions: @competitions
    }
  }

end


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
    event_location: wallet.offer.event.location,
    event_start_time: wallet.offer.event.start_time,
    event_end_time: wallet.offer.event.end_time,
    event_date: wallet.offer.event.start_date,
    price: get_formated_price(wallet.offer.price),
    quantity: wallet.offer.quantity,
    purchased_quantity: getPurchaseQuantity(wallet.offer.id),
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
            if @notification = Notification.create(recipient: friend, actor: request_user, action: get_full_name(request_user) + " has grabbed #{@wallet.offer.class.name.downcase} '#{@wallet.offer.title}'.", notifiable: @wallet.offer,  url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet')
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
      description: pass.description,
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
      location: offer.location,
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

def getPurchaseQuantity(ticket_id)
  p = TicketPurchase.where(user_id: request_user.id).where(ticket_id: ticket_id)
  if !p.blank?
    p.first.quantity
  else
    0
  end
end

private


def custom_sort(array, array2push2End)
  sorted = array - array2push2End + array2push2End
end


end
