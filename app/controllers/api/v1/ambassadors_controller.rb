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
      
      #create_activity(request_user, "sent ambassador request to #{User.get_full_name(@business)}", @ambassador_request, 'AmbassadorRequest', '', '', 'post', 'ambassador_request')

      if @notification = Notification.create(recipient: @business, actor: request_user, action: User.get_full_name(request_user) + " sent you ambassador request", notifiable: @ambassador_request, url: '/admin/ambassadors', notification_type: 'web', action_type: 'send_request')  
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
    User.businesses_list.each do |business|
   if !business.passes.blank?
      business.passes.not_expired.order(created_at: 'DESC').each do |pass| 
        @passes << get_pass_object(pass)
        end
      end #not empty
        
      if !business.special_offers.blank?
        business.special_offers.not_expired.order(created_at: 'DESC').each do |offer|
         @special_offers << get_special_offer_object(offer)
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

  # list of business who approved an ambassador
  def my_businesses
    @businesses = request_user.ambassador_businesses
    @passes = []
    @special_offers = []
    @offers = []
    @businesses.each do |business|
      if !business.passes.blank?
      business.passes.not_expired.order(created_at: 'DESC').each do |pass| 
        @passes << get_pass_object(pass)
        end
      end #not empty

      if !business.special_offers.blank?
        business.special_offers.not_expired.order(created_at: 'DESC').each do |offer|
        @special_offers << get_special_offer_object(offer)
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
