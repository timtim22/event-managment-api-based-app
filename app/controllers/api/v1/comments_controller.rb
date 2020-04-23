class Api::V1::CommentsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def create
    @event = Event.find(params[:event_id])
    @comment = @event.comments.new
    @comment.user = request_user
    @comment.user_avatar = request_user.avatar.url
    @comment.from = User.get_full_name(request_user) 
    @comment.comment = params[:comment]
    if @comment.save
      # resource should be parent resource in case of api so that event id should be available in order to show event based comment.
      action_arg = "commented on event '#{@event.name}'";
      create_activity(action_arg, @event, 'Event', admin_event_path(@event), @event.name, 'post')
      # Notify the event owner as well
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
     if @notification = Notification.create(recipient: @event.user, actor: request_user, action: if request_user == @event.user then "You commented on your event '#{@event.name}'" else User.get_full_name(request_user) + " posted a new comment on your event '#{@event.name}'." end, notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'web',action_type: 'comment')  
        @pubnub.publish(
          channel: [@event.user.id.to_s],
          message: { 
            action: @notification.action,
            avatar: request_user.avatar.url,
            time: time_ago_in_words(@notification.created_at),
            notification_url: @notification.url
           }
        ) do |envelope|
          puts envelope.status
        end
      end ##notification create
       #also notify who commented on the event
        @event.comments.each do |comment|
      if comment.user != request_user
           @setting = EventSetting.where(event_id: @event.id).where(user_id: comment.user.id)
        if !@setting.blank? && !@setting.mute_notifications 
        if @notification = Notification.create(recipient: comment.user, actor: request_user, action: User.get_full_name(request_user) + " commented on event '#{@event.name}'.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile_web',action_type: 'comment')  
          @push_channel = "event" #encrypt later
          @current_push_token = @pubnub.add_channels_to_push(
             push_token: comment.user.device_token,
             type: 'gcm',
             add: comment.user.device_token
             ).value
  
           payload = { 
            "pn_gcm":{
             "notification":{
               "title": @event.name,
               "body": @notification.action
             },
             data: {
              "id": @notification.id,
              "sender_name": User.get_full_name(request_user),
              "actor_id": @notification.actor_id,
              "actor_image": @notification.actor.avatar.url,
              "notifiable_id": @notification.notifiable_id,
              "notifiable_type": @notification.notifiable_type,
              "action": @notification.action,
              "action_type": @notification.action_type,
              "created_at": @notification.created_at,
              "body": @comment.comment    
             }
            }
           }
           @pubnub.publish(
            channel: comment.user.device_token,
            message: payload
            ) do |envelope|
                puts envelope.status
           end
        end ##notification create
       end #setting
      end #not request_user
      end #each
 
       render json: {
         success: true,
         message: "Comment created successfully"
       }
    else 
      render json: {
         success: false,
         message: @comment.errors.full_messages
       }
    end 
    
   end

   def comments
    @event = Event.find(params[:event_id])
    @comments = @event.comments 
    render json: {
     code: 200,
     success: true,
     message: '',
     data:  {
        comments:  @comments 
     }    
   
  }
   end

   def get_commented_events
     @events_with_last_comment = []
     @commented_events = Comment.all.map {|comment| 
     @events_with_last_comment << {
       "event" => comment.event,
       "last_comment" => comment.event.comments.order(created_at: 'DESC').first
     }
    }
     render json:  {
       code: 200,
       success: true,
       message: '',
       data: {
         commented_events: @events_with_last_comment.uniq
       }
     }
   end
end