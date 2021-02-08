class Api::V1::Users::AmbassadorsController < Api::V1::ApiMasterController
  before_action :authorize_request

  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  api :POST, '/api/v1/ambassadors/send-request', 'Send Ambassador Request'
  param :business_id, :number, :desc => "Business ID", :required => true

  def send_request
    if !params[:business_id].blank?
    @business = User.find(params[:business_id])
    check = @business.business_ambassador_requests.where(user_id: request_user.id)
    if check.blank?
    if  @ambassador_request = @business.business_ambassador_requests.create!(user_id: request_user.id)


       approve_ambassador(@ambassador_request.business, @ambassador_request.id)


      if @notification = Notification.create(recipient: @business, actor: request_user, action: get_full_name(request_user) + " sent you ambassador request", notifiable: @ambassador_request,resource: @ambassador_request, url: '/admin/ambassadors', notification_type: 'web', action_type: 'send_request')
        @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
          @pubnub.publish(
          channel: [@business.id],
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
      render json:  {
        code: 200,
        success: true,
        message: "Ambassador request sent.",
        user: request_user,
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

  api :GET, '/api/v1/ambassadors/businesses-list', 'Get list of businesses'

  def businesses_list
    @businesses = []
    @passes = []
    @special_offers = []
    @offers = []
    User.businesses_list.each do |business|
   if !business.passes.blank?
      business.passes.not_expired.order(created_at: 'DESC').each do |pass|
        @passes << {
          id: pass.id,
          type: 'pass',
          title: pass.title,
          description: pass.description,
          host_name:  get_full_name(business),
          host_image: business.avatar,
          event_name: pass.event.title,
          event_image: pass.event.image,
          event_location: eval(pass.event.location),
          event_start_time: pass.event.start_time,
          event_end_time: pass.event.end_time,
          event_date: pass.event.start_date,
          distributed_by: distributed_by(pass),
          is_added_to_wallet: is_added_to_wallet?(pass.id),
          validity: pass.validity.strftime(get_time_format),
          grabbers_count: pass.wallets.size,
          ambassador_rate: pass.ambassador_rate,
          quantity: pass.quantity,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: pass.created_at,
          terms_and_conditions: pass.terms_conditions,
          redeem_count: get_redeem_count(pass),
          issued_by: get_full_name(business),
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
          grabbers_count: offer.wallets.size,
          is_added_to_wallet: is_added_to_wallet?(offer.id),
          grabbers_friends_count: get_friend_grabbers(request_user, offer).size,
          ambassador_rate: offer.ambassador_rate,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: offer.created_at,
          business: get_business_object(business),
          terms_and_conditions: offer.terms_conditions,
          issued_by: get_full_name(offer.user),
          redeem_count: get_redeem_count(offer),
          quantity: offer.quantity

        }
        end
      end #not blank
    end


   if !@passes.blank?
    @passes.each do  |pass|
      @offers.push(pass)
    end
  end #not empty

  if !@special_offers.blank?
    @special_offers.each do  |offer|
      @offers.push(offer)
    end
  end #not blank


    render json: {
      code: 200,
      success: true,
      message: '',
      data:  {
        offers: @offers
      }
    }
  end

  api :GET, '/api/v1/ambassadors/my-businesses', 'Get list of businesses who accepted an ambassador'
  # list of business who approved an ambassador
  def my_businesses
    @businesses = request_user.ambassador_businesses
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
          event_name: pass.event.title,
          event_image: pass.event.image,
          event_location: eval(pass.event.location),
          event_date: pass.event.start_date,
          distributed_by: distributed_by(pass),
          is_added_to_wallet: is_added_to_wallet?(pass.id),
          validity: pass.validity.strftime(get_time_format),
          grabbers_count: pass.wallets.size,
          ambassador_stats: ambassador_stats(pass, request_user),
          ambassador_rate: pass.ambassador_rate,
          quantity: pass.quantity,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: pass.created_at,
          issued_by: get_full_name(business),
          terms_and_conditions: pass.terms_conditions,
          redeem_count: get_redeem_count(pass),
          business: get_business_object(business),

        }
        end #each
      end #not empty

      if !business.special_offers.blank?
        business.special_offers.not_expired.order(created_at: 'DESC').each do |offer|
        @offers << {
          id: offer.id,
          type: 'special_offer',
          title: offer.title,
          description: offer.description,
          sub_title: offer.sub_title,
          location: eval(offer.location),
          date: offer.date,
          time: offer.time,
          lat: offer.lat,
          lng: offer.lng,
          image: offer.image.url,
          creator_name: offer.user.business_profile.profile_name,
          creator_image: offer.user.avatar,
          validity: offer.validity.strftime(get_time_format),
          end_time: offer.validity,
          grabbers_count: offer.wallets.size,
          ambassador_stats: ambassador_stats(offer, request_user),
          is_added_to_wallet: is_added_to_wallet?(offer.id),
          grabbers_friends_count: offer.wallets.map {|wallet|  if (request_user.friends.include? wallet.user) then wallet.user end }.size,
          ambassador_rate: offer.ambassador_rate,
          "ambassador_request_status" =>  get_request_status(business.id),
          created_at: offer.created_at,
          business: get_business_object(business),
          terms_and_conditions: offer.terms_conditions,
          issued_by: get_full_name(offer.user),
          redeem_count: get_redeem_count(offer),
          quantity: offer.quantity
        }
        end #each
      end #not empty
    end #parant each

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        total_earning: request_user.profile.earning,
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





end
