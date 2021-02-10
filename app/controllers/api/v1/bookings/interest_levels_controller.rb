class Api::V1::Bookings::InterestLevelsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  api :POST, '/api/v1/bookings/create-interest', 'To create interest'
  param :event_id, Integer, :desc => "Event ID", :required => true

 def create_interest
    if !params[:event_id].blank?
    user = request_user
    @event = ChildEvent.find(params[:event_id])
  
   
    check = @event.interest_levels.where(user_id: user.id).where(level: 'interested').first
    if check.blank?
    if @interest_level = @event.interest_levels.create!(user_id: user.id, level: 'interested')
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
      create_activity(request_user, "interested in event '#{@event.title}'", @event, 'ChildEvent', admin_event_path(@event), @event.title, 'post', 'interested')

      if @notification = Notification.create(recipient: @event.user, actor: request_user, action: get_full_name(request_user) + " is interested in your event '#{@event.title}'.", notifiable: @event, resource: @interest_level, url: "/admin/events/#{@event.id}", notification_type: 'mobile_web', action_type: 'create_interest')
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
         )
        @pubnub.publish(
          channel: [@event.user.id.to_s],
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

      #also notify request_user friends
     if !request_user.friends.blank?
      request_user.friends.each do |friend|

      if notification = Notification.create(recipient: friend, actor: request_user, action: get_full_name(request_user) + " is interested in event '#{@event.title}'.", notifiable: @interest_level, resource: @interest_level, url: "/admin/events/#{@event.id}", notification_type: 'mobile_web', action_type: 'create_interest')

        if !mute_push_notification?(user) && !mute_event_notifications?(user, @event)

        @current_push_token = @pubnub.add_channels_to_push(
           push_token: friend.device_token,
           type: 'gcm',
           add: friend.device_token
    
           ).value

         payload = {
          "pn_gcm":{
           "notification":{
             "title": @event.title,
             "body": notification.action
           },
           data: {

            "id": notification.id,
            "business_name": get_full_name(notification.resource.child_event.user),
            "friend_name": get_full_name(notification.resource.user),
            "event_name": notification.resource.child_event.title,
            "event_id": notification.resource.child_event.id,
            "event_start_date": notification.resource.child_event.start_date,
            "event_location": notification.resource.child_event.location,
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "interest_level": notification.resource.level
           }
          }
         }
         @pubnub.publish(
          channel: friend.device_token,
          message: payload
          ) do |envelope|
              puts envelope.status
         end
        end # setting
      end ##notification create
    end #each
    end #if not blank
      render json: {
        code: 200,
        success: true,
        message: 'You showed your interest.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: @interest_level.errors.full_messages,
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: 'Already shown your interest.',
      data: nil
    }
  end
    else
      render json: {
        code: 400,
        success: false,
        message: 'Event id is required.',
        data: nil
      }
    end
 end



   api :POST, '/api/v1/bookings/create-going', 'To create going'
  param :event_id, Integer, :desc => "Event ID", :required => true

 def create_going
  if !params[:event_id].blank?
  user = request_user
  @event = ChildEvent.find(params[:event_id])
  check = @event.interest_levels.where(user_id: user.id).where(level: 'going').first
  if check.blank?
  if @interest_level = @event.interest_levels.create!(user_id: user.id, level: 'going')
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        create_activity(request_user, "going to attend an event", @event, 'ChildEvent', admin_event_path(@event), @event.title, 'post', 'going')
    if @notification = Notification.create(recipient: @event.user, actor: request_user, action: get_full_name(request_user) + " is going to attend your event '#{@event.title}'.", notifiable: @event, resource: @interest_level, url: "/admin/events/#{@event.id}", notification_type: 'web', action_type: 'create_going')

   

      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )


      @pubnub.publish(
        channel: [@event.user.id.to_s],
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

      #also notify request_user friends
      if !request_user.friends.blank?
        request_user.friends.each do |friend|
     
        if notification = Notification.create(recipient: friend, actor: request_user, action: get_full_name(request_user) + " is going to attend event '#{@event.title}'.", notifiable: @interest_level, resource: @interest_level, url: "/admin/events/#{@event.id}", notification_type: 'mobile_web', action_type: 'create_going')
         
          if !mute_push_notification?(user) && !mute_event_notifications?(user, @event)

          @current_push_token = @pubnub.add_channels_to_push(
             push_token: friend.device_token,
             type: 'gcm',
             add: friend.device_token
             ).value

           payload = {
            "pn_gcm":{
             "notification":{
               "title": @event.title,
               "body": notification.action
             },
             data: {
              "id": notification.id,
              "business_name": get_full_name(notification.resource.child_event.user),
              "friend_name": get_full_name(notification.resource.user),
              "event_name": notification.resource.child_event.title,
              "event_id": notification.resource.child_event.id,
              "event_start_date": notification.resource.child_event.start_date,
              "event_location": notification.resource.child_event.location,
              "actor_id": notification.actor_id,
              "actor_image": notification.actor.avatar,
              "notifiable_id": notification.notifiable_id,
              "notifiable_type": notification.notifiable_type,
              "action": notification.action,
              "action_type": notification.action_type,
              "created_at": notification.created_at,
              "is_read": !notification.read_at.nil?,
              "interest_level": notification.resource.level
             }
            }
           }
           @pubnub.publish(
            channel: @event.user.id.to_s,
            message: payload
            ) do |envelope|
                puts envelope.status
           end
          end #setting
        end ##notification create
      end #each
    end #if not blank
    render json: {
      code: 200,
      success: true,
      message: 'Going created successfully.',
      data: nil
    }
  else
    render json: {
      code: 400,
      success: false,
      message: 'Booked ticket successfully.',
      data: nil
    }
  end
else
  render json: {
    code: 400,
    success: false,
    message: 'Already booked ticket.',
    data: nil
  }
end
  else
    render json: {
      code: 400,
      success: false,
      message: 'Event id is required.',
      data: nil
    }
  end
end

end
