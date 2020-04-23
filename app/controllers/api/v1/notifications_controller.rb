class Api::V1::NotificationsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
 
 
  def index
    @notifications = []
    notifications = request_user.notifications
    notifications.each do |notification|
      location = {}
      location['lat'] = if !notification.location_share.blank? then notification.location_share.lat else '' end
      location['lng'] = if !notification.location_share.blank? then notification.location_share.lng else '' end
      @notifications << {
        "id": notification.id,
        "actor_id": notification.actor_id,
        "actor_image": notification.actor.avatar.url,
        "notifiable_id": notification.notifiable_id,
        "notifiable_type": notification.notifiable_type,
        "action": notification.action,
        "action_type": notification.action_type,
        "location": location,
        "created_at": notification.created_at  
      }
    end
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        notifications: @notifications
      }
    }
  end

  def mark_as_read
    @notifications = Notification.where(recipient: request_user).unread
    @notifications.update_all(read_at: Time.zone.now)
    render json: {success: true}
  end

  def ask_location
    if !params[:askee_ids].blank?
      askee_ids_array = params[:askee_ids].split(',').map {|s| s.to_i }
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
      @success = false
      askee_ids_array.each do |id|
     
      @askee = User.find(id)
      if @notification = Notification.create!(recipient: @askee, actor: request_user, action: User.get_full_name(request_user) + " is asking for your current location.", notifiable: @askee, url: "/admin/users/#{@askee.id}", notification_type: 'mobile',action_type: 'ask_location')  
        @location_request = LocationRequest.create!(user_id: request_user.id, askee_id: id, notification_id: @notification.id) 
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: @askee.device_token,
          type: 'gcm',
          add: @askee.device_token
          ).value
          
         
          payload = { 
            "pn_gcm":{
              "notification":{
                "title": User.get_full_name(request_user),
                "body": @notification.action
              },
              data: {
                "id": @notification.id,
                "actor_id": @notification.actor_id,
                "actor_image": @notification.actor.avatar.url,
                "notifiable_id": @notification.notifiable_id,
                "notifiable_type": @notification.notification_type,
                "action_type": @notification.action_type,
                "action": @notification.action,
                "created_at": @notification.created_at,
                "body": ''   
              }
            }
          }

          @pubnub.publish(
            channel: [@askee.device_token],
            message: payload
             ) do |envelope|
               puts envelope.status
           end

           @success = true
          else
            @success = false
        end ##notification create
      end # each
        if @success
          render json:  {
            code: 200,
            success: true,
            message: "Notification sent successfully.",
            data: nil
          }
        else
          render json:  {
            code: 400,
            success: false,
            message: "Notification was not sent.",
            data: nil
          }
        end
        else
          render json:  {
            code: 400,
            success: false,
            message: "askee_ids are required.",
            data: nil
          }
        end
     end

     def get_location
      if !params[:lat].blank? && !params[:lng].blank? && !params[:asker_id].blank?
       location = {}
       location['lat'] = params[:lat]
       location['lng'] = params[:lng]
       @asker = User.find(params[:asker_id])
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      if @notification = Notification.create(recipient: @asker, actor: request_user, action: User.get_full_name(request_user) + " has sent you #{if request_user.gender ==  'male' then 'his' else 'her' end } current location.", notifiable: @askee, url: "/admin/users/#{@asker.id}", notification_type: 'mobile', action_type: 'get_location')  
        
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: @asker.device_token,
          type: 'gcm',
          add: @asker.device_token
          ).value

          @channel = "event" 
           payload = { 
            "pn_gcm":{
              "notification":{
                "title": User.get_full_name(request_user),
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
            channel: @asker.device_token,
            message: payload
            ) do |envelope|
                puts envelope.status
           end

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

        end ##notification create
      else
        render json:  {
          code: 400,
          success: false,
          message: "asker_id, lat and lng is required.",
          data: nil
        }
      end
     end

     def send_location
      if !params[:lat].blank? && !params[:lng].blank? && !params[:user_ids].blank?
         ids_array = params[:user_ids].split(',').map {|s| s.to_i } # convert into array
         location = {}
         location['lat'] = params[:lat]
         location['lng'] = params[:lng]
         success = false
         @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )
         @channel = "event" 
         if ids_array.kind_of?(Array)
         ids_array.each do |id|
         
          @recipient = User.find(id)
         if @notification = Notification.create!(recipient: @recipient, actor: request_user, action: User.get_full_name(request_user) + " has sent you #{if request_user.gender ==  'male' then 'his' else 'her' end } current location.", notifiable: @recipient, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "send_location")

          @location_share = LocationShare.create!(user_id: request_user.id, recipient_id: id, lat:params[:lat], lng: params[:lng], notification_id: @notification.id)

           @current_push_token = @pubnub.add_channels_to_push(
             push_token: @recipient.device_token,
             type: 'gcm',
             add: @recipient.device_token
             ).value

            payload = { 
            "pn_gcm":{
              "notification":{
                "title": User.get_full_name(request_user),
                "body": @notification.action
              },
              data: {
                "id": @notification.id,
                "actor_id": @notification.actor_id,
                "actor_image": @notification.actor.avatar.url,
                "notifiable_id": @notification.notifiable_id,
                "notifiable_type": @notification.notifiable_type,
                "action_type": @notification.action_type,
                "location": location,
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
          message: 'lat, lng and user_ids are required fields',
          ids: params[:user_ids],
          data: nil
        }
      end
     end

     def mark_as_read
      @notifications = Notification.where(recipient: current_user).unread
      @notifications.update_all(read_at: Time.zone.now)
      render json: {
        code: 200,
        success: true,
        message: "Notification read successfully.",
        data: nil
      }
    end

    def send_events_reminder
      interested_in_events = request_user.interested_in_events
      #send reminder about interested in events
       @remider_sent = false;
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
       interested_in_events.each do |event|
        end_date = event.end_date
        end_date_yesterday = (end_date - 1.day).to_date
        now = Time.now.to_date
        if now  ==  end_date_yesterday
         check = request_user.reminders.where(event_id: event.id).where(level: 'interested')
         if check.blank?
          if @reminder = request_user.reminders.create!(event_id: event.id, level: 'interested')
            if @notification = Notification.create!(recipient: request_user, actor: request_user, action: "You are interested in event '#{event.name}' which is happening tomorrow. ", notifiable: event, url: "/admin/events/#{event.id}", notification_type: 'mobile', action_type: "event_reminder")

               @current_push_token = @pubnub.add_channels_to_push(
                 push_token: request_user.device_token,
                 type: 'gcm',
                 add: request_user.device_token
                 ).value
    
                payload = { 
                "pn_gcm":{
                  "notification":{
                    "title": "Reminder about '#{event.name}'",
                    "body": @notification.action
                  },
                  data: {
                    "id": @notification.id,
                    "actor_id": @notification.actor_id,
                    "actor_image": @notification.actor.avatar.url,
                    "notifiable_id": @notification.notifiable_id,
                    "notifiable_type": @notification.notifiable_type,
                    "action_type": @notification.action_type,
                    "location": location,
                    "action": @notification.action,
                    "action_type": @notification.action_type,
                    "created_at": @notification.created_at,
                    "body": ''   
                  }
                }
              }
       
                @pubnub.publish(
                  channel: [request_user.device_token],
                  message: payload
                   ) do |envelope|
                     puts envelope.status
                 end
                 @remider_sent = true;
               end ##notification create
           end #reminder
         end #cheak
        end #time equal
      end # each

      request_user.events_to_attend.each do |event|
        end_date = event.end_date
        end_date_yesterday = (end_date - 1.day).to_date
        now = Time.now.to_date
        if now  ==  end_date_yesterday
         check = request_user.reminders.where(event_id: event.id).where(level: 'going')
         if check.blank?
          if @reminder = request_user.reminders.create!(event_id: event.id, level: 'going')
            if @notification = Notification.create!(recipient: request_user, actor: request_user, action: "You are attening an event '#{event.name}' which is happening tomorrow. ", notifiable: event, url: "/admin/events/#{event.id}", notification_type: 'mobile', action_type: "event_reminder")

               @current_push_token = @pubnub.add_channels_to_push(
                 push_token: request_user.device_token,
                 type: 'gcm',
                 add: request_user.device_token
                 ).value
    
                payload = { 
                "pn_gcm":{
                  "notification":{
                    "title": "Reminder about '#{event.name}'",
                    "body": @notification.action
                  },
                  data: {
                    "id": @notification.id,
                    "actor_id": @notification.actor_id,
                    "actor_image": @notification.actor.avatar.url,
                    "notifiable_id": @notification.notifiable_id,
                    "notifiable_type": @notification.notifiable_type,
                    "action_type": @notification.action_type,
                    "location": location,
                    "action": @notification.action,
                    "action_type": @notification.action_type,
                    "created_at": @notification.created_at,
                    "body": ''   
                  }
                }
              }
       
                @pubnub.publish(
                  channel: [request_user.device_token],
                  message: payload
                   ) do |envelope|
                     puts envelope.status
                 end
                 @remider_sent = true;
               end ##notification create
           end #reminder
         end #cheak
        end #time equal
      end # each
      
        if  @remider_sent
          render json: {
            code: 200,
            success: true,
            message: 'Reminder sent successfully.',
            data: nil
          }    
        else
          render json: {
            code: 400,
            success: false,
            message: 'Reminder was not sent.',
            token: request_user.device_token,
            data: nil
          }  
        end 
    end

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
         if @notification = Notification.create!(recipient: @recipient, actor: request_user, action: User.get_full_name(request_user) + " has sent you #{if params[:offer_type] ==  'Pass' then 'a pass ' + @offer.title else 'a Special Offer ' + @offer.title end }.", notifiable: @offer, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{if params[:offer_type] ==  'Pass' then 'pass_recieved' else 'special_offer_recieved'  end }")

          @offer_forward = OfferForwarding.create!(user_id: request_user.id, recipient_id: id, offer_type:params[:offer_type], offer_id: params[:offer_id])

          create_activity("forwarded '#{@offer.title}' to #{User.get_full_name(@recipient)}. ", @offer_forward, 'OfferForwarding', '', '', 'post')

           @current_push_token = @pubnub.add_channels_to_push(
             push_token: @recipient.device_token,
             type: 'gcm',
             add: @recipient.device_token
             ).value

            payload = { 
            "pn_gcm":{
              "notification":{
                "title": User.get_full_name(request_user),
                "body": @notification.action
              },
              data: {
                "id": @notification.id,
                "actor_id": @notification.actor_id,
                "actor_image": @notification.actor.avatar.url,
                "notifiable_id": @notification.notifiable_id,
                "notifiable_type": @notification.notifiable_type,
                "action_type": @notification.action_type,
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
          
            if @notification = Notification.create!(recipient: @recipient, actor: @sender, action: User.get_full_name(@sender) + " has sent you #{if params[:offer_type] ==  'Pass' then 'a pass ' + @offer.title else 'a Special Offer ' + @offer.title end }.", notifiable: @offer, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{if params[:offer_type] ==  'Pass' then 'pass_recieved' else 'special_offer_recieved'  end }")
    
             @offer_share = OfferShare.create!(user_id: @sender.id, recipient_id: request_user.id, offer_type:params[:offer_type], offer_id: params[:offer_id])
    
              @current_push_token = @pubnub.add_channels_to_push(
                push_token: @recipient.device_token,
                type: 'gcm',
                add: @recipient.device_token
                ).value
    
               payload = { 
               "pn_gcm":{
                 "notification":{
                   "title": User.get_full_name(request_user),
                   "body": @notification.action
                 },
                 data: {
                   "id": @notification.id,
                   "actor_id": @notification.actor_id,
                   "actor_image": @notification.actor.avatar.url,
                   "notifiable_id": @notification.notifiable_id,
                   "notifiable_type": @notification.notifiable_type,
                   "action_type": @notification.action_type,
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
  
end
