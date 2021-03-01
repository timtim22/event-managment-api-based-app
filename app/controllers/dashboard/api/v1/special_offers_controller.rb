class Dashboard::Api::V1::SpecialOffersController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request

    resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/special_offers', 'Get all special offers'

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

  api :GET, 'dashboard/api/v1/get-past-offers', 'Get all expired special offers'

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

  api :POST, 'dashboard/api/v1/special_offers', 'Create special offer'
  # param :title, String, :desc => "Title of the special offer", :required => true
  # param :description, String, :desc => "Description of the special offer", :required => true
  # param :date, String, :desc => "Date of the special offer", :required => true
  # param :validity, String, :desc => "Validity", :required => true
  # param :ambassador_rate, :decimal, :desc => "Ambassador rate of the special offer", :required => true
  # param :image, String, :desc => "Image of the special offer", :required => true
  # param :qr_code, :number, :desc => "Redeem Code", :required => true
  # param :terms_conditions, String, :desc => "Terms and condition of the special offer", :required => true

  def create
    @special_offer = request_user.special_offers.new
    @special_offer.title = params[:title]
    @special_offer.sub_title = params[:sub_title]
    @special_offer.description = params[:description]
    @special_offer.end_time = params[:end_time]
    @special_offer.date = params[:date]
    @special_offer.time = params[:time]
    @special_offer.validity = params[:validity]
    @special_offer.ambassador_rate = params[:ambassador_rate]
    @special_offer.image = params[:image]
    @special_offer.qr_code = generate_code
    @special_offer.terms_conditions = params[:terms_conditions]
    if !params[:location].blank?
      @special_offer.location = params[:location][:name]
      @special_offer.lat = params[:location][:geometry][:lat]
      @special_offer.lng = params[:location][:geometry][:lng]
    end

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
      if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " created new special offer '#{@special_offer.title}'.", notifiable: @special_offer, resource: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'create_offer')
        @current_push_token = @pubnub.add_channels_to_push(
         push_token: follower.device_token,
         type: 'gcm',
         add: follower.device_token
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
         channel: follower.device_token,
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

  api :POST, 'dashboard/api/v1/special_offers', 'Update special offer'
  # param :id, :number, :desc => "ID of the special offer", :required => true
  # param :title, String, :desc => "Title of the special offer", :required => true
  # param :description, String, :desc => "Description of the special offer", :required => true
  # param :date, String, :desc => "Date of the special offer", :required => true
  # param :validity, String, :desc => "Validity", :required => true
  # param :ambassador_rate, :number, :desc => "Ambassador rate of the special offer", :required => true
  # param :image, String, :desc => "Image of the special offer", :required => true
  # param :qr_code, String, :desc => "Redeem Code", :required => true
  # param :terms_conditions, String, :desc => "Terms and condition of the special offer", :required => true
 # param :id, :number, :desc => "Title of the competition", :required => true

def update
  if !params[:id].blank?
    @special_offer = SpecialOffer.find(params[:id])
    @special_offer.title = params[:title]
    @special_offer.description = params[:description]
    @special_offer.date = params[:date]
    @special_offer.time = params[:time]
    @special_offer.validity = params[:validity]
    @special_offer.ambassador_rate = params[:ambassador_rate]
    @special_offer.image = params[:image]
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
      if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " updated special offer '#{@special_offer.title}'.", notifiable: @special_offer, resource: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'create_offer')

        @current_push_token = @pubnub.add_channels_to_push(
        push_token: follower.device_token,
        type: 'gcm',
        add: follower.device_token
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
        channel: follower.device_token,
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

  api :DELETE, 'dashboard/api/v1/special_offers', 'Delete special offer'
  param :id, :number, :desc => "ID of the special offer", :required => true

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


