class Dashboard::Api::V1::SpecialOffersController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request

  def index
    @special_offers = request_user.special_offers.page(params[:page]).per(20).order(id: 'DESC')
    @offers = []
    @special_offers.each do |offer|
      location = {
        name: offer.location,
        geometry: {
          lat: offer.lat,
          lng: offer.lng
        }
      }
      @offers << {
        id: offer.id,
        title: offer.title,
        image: offer.image.url,
        location: location,
        validity: offer.validity,
        description: offer.description,
        ambassador_rate: offer.ambassador_rate,
        terms_conditions: offer.terms_conditions
      }
    end
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        special_offers: @offers
      }
    }
  end

  def get_past_offers
    @special_offers = []
    SpecialOffer.page(params[:page]).per(20).expired.order(created_at: "DESC").each do |offer|
      location = {
        "name" => offer.location,
        "geometry" => {
          "lat" => offer.lat,
          'lng' => offer.lng
        }
     }

      @special_offers << {
        id: offer.id,
        title: offer.title,
        image: offer.image,
        location: location,
        views: offer.views.size,
        published: offer.created_at.strftime("%a %d %b %y - %H:%M "),
        redeem_count: get_redeem_count(offer),
    }
    end
    render json:  {
      code: 200,
      success: true,
      message: '',
      data:  {
        special_offers: @special_offers
      }
    }
  end

  def create
    @special_offer = SpecialOffer.new
    @special_offer.title = params[:title]
    @special_offer.description = params[:description]
    @special_offer.date = params[:date]
    @special_offer.validity = params[:validity]
    @special_offer.ambassador_rate = params[:ambassador_rate]
    @special_offer.image = params[:image]
    @special_offer.redeem_code = generate_code
    @special_offer.terms_conditions = params[:terms_conditions]
    @special_offer.location = params[:location]


    if @special_offer.save
     # create_activity(request_user, "created special offer", @special_offer, "SpecialOffer", admin_special_offer_path(@special_offer),@special_offer.title, 'post', 'created_special_offer')
      if !request_user.followers.blank?
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY'],
          uuid: @username
          )
      request_user.followers.each do |follower|
   if follower.special_offers_notifications_setting.is_on == true
      if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " created new special offer '#{@special_offer.title}'.", notifiable: @special_offer, resource: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'create_event')
        @channel = "event" #encrypt later
        @current_push_token = @pubnub.add_channels_to_push(
         push_token: follower.profile.device_token,
         type: 'gcm',
         add: follower.profile.device_token
         ).value

         payload = {
          "pn_gcm":{
           "notification":{
             "title": get_full_name(request_user),
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
         channel: follower.profile.device_token,
         message: payload
         ) do |envelope|
             puts envelope.status
        end
       end # notificatiob end
      end #special offer setting end
      end #each
      end # not blank
      render json: {
        code: 200,
        success: true,
        message: 'Special offer created successfully.',
        data: nil
      }

    else
      render json: {
        code: 400,
        success: false,
        message: @special_offer.errors.full_messages,
        data: nil

      }
    end
end

def edit

end


def update
  if !params[:id].blank?
    @special_offer = SpecialOffer.find(params[:id])
    @special_offer.title = params[:title]
    @special_offer.description = params[:description]
    @special_offer.date = params[:date]
    @special_offer.validity = params[:validity]
    @special_offer.ambassador_rate = params[:ambassador_rate]
    @special_offer.image = params[:image]
    @special_offer.is_redeemed = false
    @special_offer.terms_conditions = params[:terms_conditions]
    if !params[:location].blank?
      @special_offer.location = params[:location][:name]
      @special_offer.lat = params[:location][:geometry][:lat]
      @special_offer.lng = params[:location][:geometry][:lng]
    end

    if @special_offer.save
      # create_activity(request_user, "updated special offer", @special_offer, "SpecialOffer", admin_special_offer_path(@special_offer),@special_offer.title, 'put', 'updated_special_offer')
      if !request_user.followers.blank?
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY'],
          uuid: @username
          )
      request_user.followers.each do |follower|
  if follower.special_offers_notifications_setting.is_on == true
      if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " updated special offer '#{@special_offer.title}'.", notifiable: @special_offer, resource: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'create_event')

        @current_push_token = @pubnub.add_channels_to_push(
        push_token: follower.profile.device_token,
        type: 'gcm',
        add: follower.profile.device_token
        ).value

        payload = {
          "pn_gcm":{
          "notification":{
            "title": get_full_name(request_user),
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
        channel: follower.profile.device_token,
        message: payload
        ) do |envelope|
            puts envelope.status
        end
      end # notificatiob end
      end #special offer setting end
      end #each
      end # not blank
      render json: {
        code: 200,
        success: true,
        message: 'Special offer updated successfully.',
        data: {
          special_offer: @special_offer
        }
      }

    else
      render json: {
        code: 400,
        success: false,
        message: @special_offer.errors.full_messages,
        data: nil

      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "id is required.",
      data: nil

    }
  end
end


 def destroy
  special_offer = SpecialOffer.find(params[:id])
  if special_offer.destroy
    render json: {
      code: 200,
      success: true,
      message: 'Special offer successfully deleted.',
      data: nil
    }
  else
    render json:  {
      code: 400,
      success: false,
      message: 'Special offer deletion failed.',
      data: nil
    }
  end
 end



 private

  def get_redeem_count(offer)
     if offer.redemptions
       offer.redemptions.size
     else
      0
     end
  end



end


