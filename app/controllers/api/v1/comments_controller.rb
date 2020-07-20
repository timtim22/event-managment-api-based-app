class Api::V1::CommentsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['comments','get_commented_events']
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def create
    @event = Event.find(params[:event_id])
    if !blocked_event?(request_user, @event)
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
        @comment_users = []
         @event.comments.each do |comment|
          @comment_users.push(comment.user)
         end #each
        @comment_users.uniq.each do |comment_user|
      if comment_user != request_user
      
        if @notification = Notification.create(recipient: comment_user, actor: request_user, action: User.get_full_name(request_user) + " commented on event '#{@event.name}'.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile_web',action_type: 'comment')  

         if !event_chat_muted?(request_user, @event) && comment_user.all_chat_notifications_setting.is_on == true && comment_user.event_notifications_setting.is_on == true

          @current_push_token = @pubnub.add_channels_to_push(
             push_token: comment_user.device_token,
             type: 'gcm',
             add: comment_user.device_token
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
              "body": @comment.comment,
              "last_comment": @comment    
             }
            }
           }
           @pubnub.publish(
            channel: comment_user.device_token,
            message: payload
            ) do |envelope|
                puts envelope.status
           end #publish
          end# mute if
        end ##notification create
   
      end #not request_user
      end #each
 
       render json: {
         code: 200,
         success: true,
         message: "Comment created successfully",
         data: nil
       }
    else 
      render json: {
         success: false,
         message: @comment.errors.full_messages
       }
    end 

  else
    render json: {
      code:400,
      success: false,
      message: "You have blocked the event, first unblock it to send the message.",
      data: nil
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
     @events = []
     @commented_events = request_user.comments.map {|comment| 
       e = comment.event
       @events << {
        'id' => e.id,
        'name' => e.name,
        'creator_name' => e.user.first_name + " " + e.user.last_name,
        'creator_id' => e.user.id,
        'creator_image' => e.user.avatar.url,
        "is_blocked" => blocked_event?(request_user, e),
        "is_mute" => event_chat_muted?(request_user, e),
        "last_comment" => comment.event.comments.order(created_at: 'DESC').first,
        "unread_count" => get_unread_comments_count(e)
       }
    }#map

     render json:  {
       code: 200,
       success: true,
       message: '',
       data: {
         commented_events: @events.uniq
       }
     }
   end



   def delete_event_comments
     if !params[:event_id].blank?
       event = Event.find(params[:event_id])
        comments = event.comments.where(user_id: request_user.id)
        if comments.destroy_all
          render json: {
            code: 200,
            success: true,
            message: "Event chat cleard.",
            data: nil
          }
        else
          render json: {
            code: 400,
            success: false,
            message: "Event chat removal failed.",
            data: nil
          }
        end
        else
          render json: {
            code: 400,
            success: false,
            message: 'event_id is required field.',
            data: nil
          }
        end   
   end


def mark_as_read
  if !params[:event_id].blank?
    event = Event.find(params[:event_id])
    if event.comments.unread.update_all(read_at: Time.zone.now, reader_id: request_user.id)
      render json: {
        code: 200,
        success: true,
        message: "Messages read successfully.",
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "Message read failed.",
        data: nil
      }
    end
  else

    render json: {
      code: 400,
      success: false,
      message: "event_id is required field.",
      data: nil
    }

  end
end


   private

   def get_unread_comments_count(event)
     count = event.comments.where.not(user_id: request_user.id).where(reader_id: nil).or(event.comments.where.not(reader_id: request_user.id).where.not(user_id: request_user.id)).unread.size
   end


end