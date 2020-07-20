class Admin::SpecialOffersController < Admin::AdminMasterController
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def index
    @special_offers = current_user.special_offers.order(created_at: "DESC")
  end

  def new
    @special_offer = SpecialOffer.new
  end

  def show
    @special_offer = SpecialOffer.find(params[:id])
  end

  def create
      @special_offer = SpecialOffer.new
      @special_offer.title = params[:title]
      @special_offer.description = params[:description]
      @special_offer.user = current_user
      @special_offer.sub_title = params[:sub_title]
      @special_offer.location = params[:location]
      @special_offer.lat = params[:lat]
      @special_offer.lng = params[:lng]
      @special_offer.date = params[:date]
      @special_offer.time = params[:time]
      @special_offer.end_time = params[:end_time]
      @special_offer.image = params[:image]
      @special_offer.redeem_code = params[:redeem_code]
      @special_offer.is_redeemed = false
      @special_offer.terms_conditions = params[:terms_conditions]
      @special_offer.validity = params[:validity]
      if @special_offer.save
        create_activity("created special offer", @special_offer, "SpecialOffer", admin_special_offer_path(@special_offer),@special_offer.title, 'post')
        if !current_user.followers.blank?
          @pubnub = Pubnub.new(
            publish_key: ENV['PUBLISH_KEY'],
            subscribe_key: ENV['SUBSCRIBE_KEY'],
            uuid: @username
            )
          current_user.followers.each do |follower|
     if follower.special_offers_notifications_setting.is_on == true 
        if @notification = Notification.create!(recipient: follower, actor: current_user, action: User.get_full_name(current_user) + " created new special offer '#{@special_offer.title}'.", notifiable: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'create_event') 
          @channel = "event" #encrypt later
          @current_push_token = @pubnub.add_channels_to_push(
           push_token: follower.device_token,
           type: 'gcm',
           add: follower.device_token
           ).value
  
           payload = { 
            "pn_gcm":{
             "notification":{
               "title": User.get_full_name(current_user),
               "body": @notification.action
             },
             data: {
              "id": @notification.id,
              "actor_id": @notification.actor_id,
              "actor_image": @notification.actor.avatar.url,
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
        flash[:notice] = "special_offer created successfully."
        redirect_to admin_special_offers_path
      else
        flash[:alert_danger] = "special_offer creation failed."
        redirect_to admin_special_offers_path
      end 
  end

  def edit
    @special_offer = SpecialOffer.find(params[:id])
  end


  def update
     validity = params[:validity] + params[:validity_time]
     @special_offer = SpecialOffer.find(params[:id])
     @special_offer.title = params[:title]
     @special_offer.description = params[:description]
     @special_offer.user = current_user
     @special_offer.sub_title = params[:sub_title]
     @special_offer.location = params[:location]
     @special_offer.lat = params[:lat]
     @special_offer.lng = params[:lng]
     @special_offer.date = params[:date]
     @special_offer.time = params[:time]
     @special_offer.end_time = params[:end_time]
     @special_offer.image = params[:image]
     @special_offer.redeem_code = generate_code
     @special_offer.is_redeemed = false
     @special_offer.terms_conditions = params[:terms_conditions]
     @special_offer.validity = params[:validity] 
    if @special_offer.save
      create_activity("updated special offer", @special_offer, "SpecialOffer", admin_special_offer_path(@special_offer),@special_offer.title, 'patch')
      if !current_user.followers.blank?
        current_user.followers.each do |follower|
    if follower.special_offers_notifications_setting.is_on == true 
      if @notification = Notification.create!(recipient: follower, actor: current_user, action: User.get_full_name(current_user) + " updated special offer '#{@special_offer.title}'.", notifiable: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'update_special_offer') 
        @channel = "event" #encrypt later
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY'],
          uuid: @username
          )
        @current_push_token = @pubnub.add_channels_to_push(
         push_token: follower.device_token,
         type: 'gcm',
         add: follower.device_token
         ).value

         payload = { 
          "pn_gcm":{
           "notification":{
             "title": User.get_full_name(current_user),
             "body": @notification.action
           },
           data: {
            "id": @notification.id,
            "actor_id": @notification.actor_id,
            "actor_image": @notification.actor.avatar.url,
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
      flash[:notice] = "special_offer update successfully."
      redirect_to admin_special_offers_path
    else
      flash[:alert_danger] = @special_offer.errors.full_messages
      redirect_to admin_special_offers_path
    end 
  end

  def destroy
    @special_offer = SpecialOffer.find(params[:id])
    if @special_offer.destroy
      create_activity("deleted special offer", @special_offer, "SpecialOffer",'',@special_offer.title, 'delete')
      redirect_to admin_special_offers_path, :notice => "Special offer deleted successfully."
    else
      flash[:alert_danger] = "Special offer deletion failed."
      redirect_to admin_special_offers_path
    end
  end

  private

  def generate_code
    code = SecureRandom.hex
   end


end


