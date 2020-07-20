class Api::V1::AmbassadorsController < Api::V1::ApiMasterController
  before_action :authorize_request

  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def send_request
    if !params[:business_id].blank?
    @business = User.find(params[:business_id])
    check = @business.business_ambassador_requests.where(user_id: request_user.id)
    if check.blank?
    if  @ambassador_request = @business.business_ambassador_requests.create!(user_id: request_user.id)
      create_activity("sent ambassador request to #{User.get_full_name(@business)}", @ambassador_request, 'AmbassadorRequest', '', '', 'post')
      if @notification = Notification.create(recipient: @business, actor: request_user, action: User.get_full_name(request_user) + " sent you ambassador request", notifiable: @ambassador_request, url: '/admin/ambassadors', notification_type: 'web', action_type: 'send_request')  
        @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
          @pubnub.publish(
          channel: [@business.id],
          message: { 
            action: @notification.action,
            avatar: request_user.avatar.url,
            time: time_ago_in_words(@notification.created_at),
            notification_url: @notification.url
           }
        ) do |envelope|
          puts envelope.status
        end
      end ##notification create
      render json:  {
        code: 200,
        success: true,
        message: "Ambassador request sent.",
        data:nil
      }
    else
      render json:  {
        code: 400,
        success: false,
        message: @ambassador_request.errors.full_messages,
        data: nil
      }
    end
    else
      render json:  {
        code: 400,
        success: false,
        message: "You have already sent ambassador request to this business.",
        data: nil
      }
    end
  else
    render json:  {
        code: 400,
        success: false,
        message: "business_id is required.",
        data: nil
      }
  end   
  end

  def businesses_list
    @businesses = []
    @passes = []
    @special_offers = []
    @offers = []
    
    Assignment.all.map {|as| if as.role_id == 2 then @businesses.push(as.user) end } 

    @businesses.each do |business|
      business.passes.not_expired.order(created_at: 'DESC').each do |pass| 
        @passes << {
          id: pass.id,
          type: 'pass',
          title: pass.title,
          host_name: business.first_name + " " + business.last_name,
          host_image: business.avatar.url,
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
          ambassador_rate: pass.ambassador_rate,
          number_of_passes: pass.number_of_passes,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: pass.created_at,
          business: business 
        }
        end

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
          creator_name: offer.user.first_name + " " + offer.user.last_name,
          creator_image: offer.user.avatar.url,
          description: offer.description,
          validity: offer.validity.strftime(get_time_format),
          grabbers_count: offer.wallets.size,
          is_added_to_wallet: is_added_to_wallet?(offer.id),
          grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
          ambassador_rate: offer.ambassador_rate,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: offer.created_at,
          business: business 
        }
        end
    end
   
    @passes.each do  |pass|
      @offers.push(pass)
    end

    @special_offers.each do  |offer|
      @offers.push(offer)
    end


    render json: {
      code: 200,
      success: true,
      message: '',
      data:  {
        offers: @offers
      }
    } 
  end

  # list of business who approved an ambassador
  def my_businesses
    @businesses = request_user.ambassador_businesses
    @passes = []
    @special_offers = []
    @offers = []
    @businesses.each do |business|
      business.passes.not_expired.order(created_at: 'DESC').each do |pass| 
        @passes << {
          id: pass.id,
          type: 'pass',
          title: pass.title,
          host_name: business.first_name + " " + business.last_name,
          host_image: business.avatar.url,
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
          number_of_passes: pass.number_of_passes,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: pass.created_at,
          business: business 
        }
        end

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
          creator_name: offer.user.first_name + " " + offer.user.last_name,
          creator_image: offer.user.avatar.url,
          description: offer.description,
          validity: offer.validity.strftime(get_time_format),
          end_time: DateTime.parse(offer.end_time).strftime(get_time_format), 
          grabbers_count: offer.wallets.size,
          ambassador_stats: ambassador_stats(offer, request_user),
          is_added_to_wallet: is_added_to_wallet?(offer.id),
          grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
          ambassador_rate: offer.ambassador_rate,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: offer.created_at,
          business: business
        }
        end
    end
   
    @passes.each do  |pass|
      @offers.push(pass)
    end

    @special_offers.each do  |offer|
      @offers.push(offer)
    end

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        my_businesses: @offers
      }
    }
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

  def get_request_status(business_id)
    ar = AmbassadorRequest.where(business_id: business_id).where(user_id: request_user.id).first
    if ar
    ar.status 
    else
      'signup'
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
        @stats['total_earning'] = user.earning
    else
      @stats['info'] = "You didn't share this offer."
    end

   @stats
  end

end
