class Api::V1::PaymentsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def purchase_ticket
    if !params[:ticket_id].blank? && !params[:quantity].blank?
      @ticket = Ticket.find(params[:ticket_id])
    if params[:quantity].to_i <= @ticket.per_head && params[:quantity].to_i > 0 
      @check = TicketPurchase.where(ticket_id: params[:ticket_id]).where(user_id: request_user.id)
    if @check.blank?
    if @purchase = request_user.ticket_purchases.create!(ticket_id: params[:ticket_id], quantity: params[:quantity])
      #update total quantity
      @ticket.quantity = @ticket.quantity - params[:quantity].to_i
      @ticket.save

     if @wallet  = request_user.wallets.create!(offer_id: params[:ticket_id], offer_type: 'Ticket')

      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
     
      if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet') 

        @current_push_token = @pubnub.add_channels_to_push(
           push_token: request_user.device_token,
           type: 'gcm',
           add: request_user.device_token
           ).value

         payload = { 
          "pn_gcm":{
           "notification":{
             "title": @notification.action
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
          channel: request_user.device_token,
          message: payload
          ) do |envelope|
              puts envelope.status
         end
      end ##notification create
    end #if wallet create

      render json: {
        code: 200,
        success: true,
        message: "Ticket successfully purchased.",
        data: nil
      }

   else
    render json: {
      code: 400,
      success: false,
      message: @purchase.errors.full_messages,
      data: nil
    }
   end
  else
    render json: {
      code: 400,
      success: false,
      message: "You have already purchased this ticket.",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "Wrong quantity selected the allowd per head quantity is #{@ticket.per_head}",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "ticket_id and quantity are required.",
      data: nil
    }
  end
  end
end
