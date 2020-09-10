class Api::V1::ForwardingController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def forward_offer
    if !params[:offer_id].blank? && !params[:offer_type].blank? && !params[:user_ids].blank?
      ids_array = params[:user_ids].split(',').map {|s| s.to_i } # convert into array
        if params[:offer_type] == 'Pass'
          @offer = Pass.find(params[:offer_id])
        elsif params[:offer_type] == 'SpecialOffer'
          @offer = SpecialOffer.find(params[:offer_id])
        end

       success = false
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
       @channel = "event" 
       if ids_array.kind_of?(Array)
       ids_array.each do |id|
       @check = OfferForwarding.where(offer_id: @offer.id).where(recipient_id: id).where(user_id: request_user.id).first
       if @check.blank?  
       @recipient = User.find(id)
       if @notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has sent you #{if params[:offer_type] ==  'Pass' then 'a pass ' + @offer.title else 'a Special Offer ' + @offer.title end }.", notifiable: @offer, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{if params[:offer_type] ==  'Pass' then 'pass_recieved' else 'special_offer_recieved'  end }")

        @offer_forward = OfferForwarding.create!(user_id: request_user.id, is_ambassador: request_user.profile.is_ambassador, recipient_id: id, offer_type:params[:offer_type], offer_id: params[:offer_id])
  
       # create_activity(request_user, "forwarded '#{if params[:offer_type] == 'SpecialOffer' then 'special offer' else 'pass' end} '", @offer_forward, 'OfferForwarding', '', '', 'post', "forwarded_#{params[:offer_type]}")

         @current_push_token = @pubnub.add_channels_to_push(
           push_token: @recipient.profile.device_token,
           type: 'gcm',
           add: @recipient.profile.device_token
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
              "offer": @offer,
              "action": @notification.action,
              "action_type": @notification.action_type,
              "created_at": @notification.created_at,
              "body": ''   
            }
          }
        }
 
          @pubnub.publish(
            channel: [@recipient.profile.device_token],
            message: payload
             ) do |envelope|
               puts envelope.status
           end
           success = true
           else
           success = false
         end ##notification create
        else
          success = false
        end
      end#each

      if success
        render json: {
             code: 200,
             success: true,
             message: 'Notification sent successfully.',
             data: nil
           }
      else
        render json: {
          code: 400,
          success: false,
          message: 'Notification was not sent, please try again later.',
          data: nil
        }
      end
    else
      render json:  {
        code: 400,
        success: false,
        message: 'user_ids should be in format like "1,2,3,4"',
        data: nil
      }
    end
  
    else
      render json:  {
        code: 400,
        success: false,
        message: 'offer_id, offer_type and user_ids are required fields',
        ids: params[:user_ids],
        data: nil
      }
    end
   end

   def share_offer
    if !params[:offer_shared].blank? && params[:offer_shared] ==  'true' 
      if !params[:sender_token].blank? && !params[:offer_id].blank? && !params[:offer_type].blank?
        @sender = get_user_from_token(params[:sender_token])
        if params[:offer_type] == 'Pass'
          @offer = Pass.find(params[:offer_id])
        elsif params[:offer_type] == 'SpecialOffer'
          @offer = SpecialOffer.find(params[:offer_id])
        end
        @check = OfferShare.where(offer_id: @offer.id).where(recipient_id: request_user.id).where(user_id: @sender.id).first
        if @check.blank?  
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )
  
          @recipient = request_user
        
          if @notification = Notification.create!(recipient: @recipient, actor: @sender, action: get_full_name(@sender) + " has sent you #{if params[:offer_type] ==  'Pass' then 'a pass ' + @offer.title else 'a Special Offer ' + @offer.title end }.", notifiable: @offer, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{if params[:offer_type] ==  'Pass' then 'pass_recieved' else 'special_offer_recieved'  end }")
  
           @offer_share = OfferShare.create!(user_id: @sender.id, is_ambassador: @sender.profile.is_ambassador, recipient_id: request_user.id, offer_type:params[:offer_type], offer_id: params[:offer_id])
  
            @current_push_token = @pubnub.add_channels_to_push(
              push_token: @recipient.profile.device_token,
              type: 'gcm',
              add: @recipient.profile.device_token
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
                 "offer": @offer,
                 "action": @notification.action,
                 "action_type": @notification.action_type,
                 "created_at": @notification.created_at,
                 "body": ''   
               }
             }
           }
    
             @pubnub.publish(
               channel: [@recipient.device_token],
               message: payload
                ) do |envelope|
                  puts envelope.status
                end
            end ##notification create
  
            render json: {
              code: 200,
              success: true,
              message: 'offered shared successfully.',
              data:nil
            }
          else
            render json: {
              code: 400,
              success: false,
              message: 'offer is already shared.',
              data: nil
            }
          end
                
      else
       render json: {
         code: 400,
         success: false,
         message: 'sender_token, offer_id, offer_type are required fields',
         data: nil
       }
      end

    end
   end

  ################################# Event ##########################################33

  def forward_event
    if !params[:event_id].blank? && !params[:user_ids].blank?
      ids_array = params[:user_ids].split(',').map {|s| s.to_i } # convert into array
       
          @event = Event.find(params[:event_id])
      
       success = false
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
       @channel = "event" 
       if ids_array.kind_of?(Array)
       ids_array.each do |id|
       @check = EventForwarding.where(event_id: @event.id).where(recipient_id: id).where(user_id: request_user.id).first
       if @check.blank?  
       @recipient = User.find(id)
       if @notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has forwarded you and event.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: "forward_event")

        @event_forward = EventForwarding.create!(user_id: request_user.id, recipient_id: id, event_id: params[:event_id])

        #create_activity(request_user, "forwarded event", @event_forward, 'EventForwarding', '', '', 'post','forward_event')

         @current_push_token = @pubnub.add_channels_to_push(
           push_token: @recipient.device_token,
           type: 'gcm',
           add: @recipient.device_token
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
              "offer": @offer,
              "action": @notification.action,
              "action_type": @notification.action_type,
              "created_at": @notification.created_at,
              "body": ''   
            }
          }
        }
 
          @pubnub.publish(
            channel: [@recipient.device_token],
            message: payload
             ) do |envelope|
               puts envelope.status
           end
           success = true
           else
           success = false
         end ##notification create
        else
          success = false
        end
      end#each

      if success
        render json: {
             code: 200,
             success: true,
             message: 'Event forwarded successfully.',
             data: nil
           }
      else
        render json: {
          code: 400,
          success: false,
          message: 'Event farward failed, please try again later.',
          data: nil
        }
      end
    else
      render json:  {
        code: 400,
        success: false,
        message: 'user_ids should be in format like "1,2,3,4"',
        data: nil
      }
    end
  
    else
      render json:  {
        code: 400,
        success: false,
        message: 'event_id and user_ids are required fields',
        ids: params[:user_ids],
        data: nil
      }
    end
   end

   def share_event
    if !params[:event_shared].blank? && params[:event_shared] ==  'true' 
      if !params[:sender_token].blank? && !params[:event_id].blank?
        @sender = get_user_from_token(params[:sender_token])
       
        @event = Event.find(params[:event_id])
        
        @check = EventShare.where(event_id: @event.id).where(recipient_id: request_user.id).where(user_id: @sender.id).first
        if @check.blank?  
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )
  
          @recipient = request_user
        
          if @notification = Notification.create!(recipient: @recipient, actor: @sender, action: get_full_name(@sender) + " shared an event with you.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: "share_event")
  
           @event_share = EventShare.create!(user_id: @sender.id, recipient_id: request_user.id, event_id: params[:event_id])
  
            @current_push_token = @pubnub.add_channels_to_push(
              push_token: @recipient.device_token,
              type: 'gcm',
              add: @recipient.device_token
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
                 "action_type": @notification.action_type,
                 "offer": @offer,
                 "action": @notification.action,
                 "created_at": @notification.created_at,
                 "body": ''   
               }
             }
           }
    
             @pubnub.publish(
               channel: [@recipient.profile.device_token],
               message: payload
                ) do |envelope|
                  puts envelope.status
                end
            end ##notification create
  
            render json: {
              code: 200,
              success: true,
              message: 'Event shared successfully.',
              data:nil
            }
          else
            render json: {
              code: 400,
              success: false,
              message: 'Event is already shared.',
              data: nil
            }
          end
                
      else
       render json: {
         code: 400,
         success: false,
         message: 'sender_token and event_id are required fields',
         data: nil
       }
      end

    end
   end

end
