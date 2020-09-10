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
        "actor_image": notification.actor.avatar,
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
        notifications: @notifications,
        "unread_count": request_user.notifications.unread.size
      }
    }
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
      if @notification = Notification.create!(recipient: @askee, actor: request_user, action: get_full_name(request_user) + " is asking for your current location.", notifiable: @askee, url: "/admin/users/#{@askee.id}", notification_type: 'mobile',action_type: 'ask_location')  
        @location_request = LocationRequest.create!(user_id: request_user.id, askee_id: id, notification_id: @notification.id) 
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: @askee.profile.device_token,
          type: 'gcm',
          add: @askee.profile.device_token
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
                "notifiable_type": @notification.notification_type,
                "action_type": @notification.action_type,
                "action": @notification.action,
                "created_at": @notification.created_at,
                "body": ''   
              }
            }
          }

          @pubnub.publish(
            channel: [@askee.profile.device_token],
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
      if @notification = Notification.create(recipient: @asker, actor: request_user, action: get_full_name(request_user) + " has sent you #{if request_user.gender ==  'male' then 'his' else 'her' end } current location.", notifiable: @askee, url: "/admin/users/#{@asker.id}", notification_type: 'mobile', action_type: 'get_location')  
        
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: @asker.profile.device_token,
          type: 'gcm',
          add: @asker.profile.device_token
          ).value

          @channel = "event" 
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
            channel: @asker.profile.device_token,
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
         if @notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has sent you #{if request_user.profile.gender ==  'male' then 'his' else 'her' end } current location.", notifiable: @recipient, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "send_location")

          @location_share = LocationShare.create!(user_id: request_user.id, recipient_id: id, lat:params[:lat], lng: params[:lng], notification_id: @notification.id)

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
                "action_type": @notification.action_type,
                "location": location,
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
        if request_user.notifications.unread.update_all(read_at: Time.zone.now)
          render json: {
            code: 200,
            success: true,
            message: "Notification read successfully.",
            data: nil
          }
        else
          render json: {
            code: 400,
            success: false,
            message: "Notification read failed.",
            data: nil
          }
        end
    end

    def send_events_reminder
      interested_in_events = request_user.interested_in_events
      #send reminder about interested in events
       @reminder_sent = false;
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
                 push_token: request_user.profile.device_token,
                 type: 'gcm',
                 add: request_user.profile.device_token
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
                    "actor_image": @notification.actor.avatar,
                    "notifiable_id": @notification.notifiable_id,
                    "notifiable_type": @notification.notifiable_type,
                    "action_type": @notification.action_type,
                    "location": location,
                    "action": @notification.action,
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
                 @reminder_sent = true;
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
                    "actor_image": @notification.actor.avatar,
                    "notifiable_id": @notification.notifiable_id,
                    "notifiable_type": @notification.notifiable_type,
                    "action_type": @notification.action_type,
                    "location": location,
                    "action": @notification.action,
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
                 @reminder_sent = true;
               end ##notification create
           end #reminder
         end #cheak
        end #time equal
      end # each
      
        if  @reminder_sent
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
            token: request_user.profile.device_token,
            data: nil
          }  
        end 
    end

 
  
end
