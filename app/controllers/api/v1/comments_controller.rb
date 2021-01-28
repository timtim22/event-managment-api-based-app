class Api::V1::CommentsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['comments','get_commented_events']
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  api :POST, '/api/v1/event/post-comment', 'Post event based comment'
  # param :event_id, :number, :desc => "Event ID", :required => true
  # param :comment, String, :desc => "Comment", :required => true
  # param :is_reply, String, :desc => "True/False", :required => true

  def create

   if !params[:event_id].blank? && !params[:is_reply].blank?
    @event = ChildEvent.find(params[:event_id])
    if !blocked_event?(request_user, @event)
    if params[:is_reply] == 'false'
     @comment = @event.comments.new
     @comment.user = request_user
     @comment.user_avatar = request_user.avatar
     @comment.from = get_full_name(request_user)
     @comment.comment = params[:comment]
     if @comment.save
      # resource should be parent resource in case of api so that event id should be available in order to show event based comment.
      # Notify the event owner as well
      comment_hash = {
        "id" =>  @comment.id,
        "comment" => @comment.comment,
        "user_id" => @comment.user_id,
        "event_id" => @comment.event_id,
        "created_at": @comment.created_at,
        "updated_at" => @comment.updated_at,
        "from" => get_full_name(@comment.user),
        "user_avatar" => @comment.user.avatar,
        "read_at": @comment.read_at,
        "reader_id" => @comment.reader_id,
        "is_host" => is_host?(@comment.user, @event)
       }
     

     if @notification = Notification.create(recipient: @event.user, actor: request_user, action: if request_user == @event.user then "You commented on your event '#{@event.name}'" else get_full_name(request_user) + " posted a new comment on your event '#{@event.name}'." end, notifiable: @event, resource: @comment, url: "/admin/events/#{@event.id}", notification_type: 'web',action_type: 'comment')

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
       #also notify who commented on the event
        @comment_users = []
         @event.comments.each do |comment|
          @comment_users.push(comment.user)
         end #each
        @comment_users.uniq.each do |comment_user|
      if comment_user != request_user


        if notification = Notification.create(recipient: comment_user, actor: request_user, action: get_full_name(request_user) + " commented on event '#{@event.name}'.", notifiable: @event, resource: @comment, url: "/admin/events/#{@event.id}", notification_type: 'mobile_web',action_type: 'comment')

          if !mute_push_notification?(comment_user) && !mute_event_notifications?(comment_user, @event)

          @current_push_token = @pubnub.add_channels_to_push(
             push_token: comment_user.device_token,
             type: 'gcm',
             add: comment_user.device_token
             ).value



           payload = {
            "pn_gcm":{
             "notification":{
               "title": @event.name,
               "body": notification.action
             },
             data: {
              "id": notification.id,
              "user_name": User.get_full_name(notification.resource.user),
              "comment": notification.resource.comment,
              "event_name": notification.resource.child_event.name,
              "user_id": notification.resource.user.id,
              "event_id": notification.resource.child_event.id,
              "actor_id": notification.actor_id,
              "actor_image": notification.actor.avatar,
              "notifiable_id": notification.notifiable_id,
              "notifiable_type": notification.notifiable_type,
              "action": notification.action,
              "action_type": notification.action_type,
              "created_at": notification.created_at,
              "is_read": !notification.read_at.nil?,
              "last_comment": comment_hash,
              "comment_id": @comment.id,
              "is_host": is_business?(@comment.user)
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
         data: {
           comment: comment_hash
         }
       }
    else
      render json: {
         success: false,
         message: @comment.errors.full_messages
       }
    end
     else
     if !params[:comment_id].blank?

         @comment = Comment.find(params[:comment_id])

      if @reply = @comment.replies.create!(user: request_user, msg: params[:comment])
        reply_hash = {
          "id" =>  @reply.id,
          "comment" => @reply.msg,
          "user_id" => @reply.user_id,
          "from" => get_full_name(@reply.user),
          "avatar" => @reply.user.avatar,
          "created_at": @reply.created_at,
          "is_host" => is_host?(@reply.user,  @event)
         }
       # resource should be parent resource in case of api so that event id should be available in order to show event based comment.
       action_arg = "commented on event '#{@event.name}'";
      # create_activity(action_arg, @event, 'Event', admin_event_path(@event), @event.name, 'post')
       # Notify the event owner as well
     
   

      if @notification = Notification.create!(recipient: @event.user, actor: request_user, action: if request_user == @event.user then "You commented on your event '#{@event.name}'" else get_full_name(request_user) + " posted a new comment on your event '#{@event.name}'." end, notifiable: @event, resource: @comment, url: "/admin/events/#{@event.id}", notification_type: 'web',action_type: 'comment')

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
        #also notify who commented on the event
        if @comment.user != request_user
        if notification = Notification.create!(recipient: @comment.user, actor: request_user, action: "#{User.get_full_name(request_user)}  replied to your comemnt on the event '#{@event.name}'.", notifiable: @reply, resource: @reply, url: "/admin/events/#{@event.id}", notification_type: 'mobile_web',action_type: 'reply_comment')

         if !mute_push_notification?(@comment.user) && !mute_event_notifications?(@comment.user, @event)

           @current_push_token = @pubnub.add_channels_to_push(
              push_token: @comment.user.device_token,
              type: 'gcm',
              add: @comment.user.device_token
              ).value

            payload = {
             "pn_gcm":{
              "notification":{
                "title": @event.name,
                "body": notification.action
              },
              data: {

                "id": notification.id,
                "event_id": notification.resource.comment.event.id,
                "event_name": notification.resource.comment.event.name,
                "replier_id": notification.resource.user.id,
                "replier_name": User.get_full_name(notification.resource.user),
                "comment_id": notification.resource.comment.id,
                "comment": notification.resource.msg,
                "actor_id": notification.actor_id,
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?,
                "last_comment": reply_hash,
                "reply_id": @reply.id,
                "is_host": is_business?(@reply.user)
              }
             }
            }
            @pubnub.publish(
             channel: @comment.user.device_token,
             message: payload
             ) do |envelope|
                 puts envelope.status
            end #publish
           end# mute if
         end ##notification create
        end #comment_user not equal to request user


        render json: {
          code: 200,
          success: true,
          message: "Replied successfully",
          data: {
            reply: reply_hash
           }
        }
     else
       render json: {
          success: false,
          message: @reply.errors.full_messages
        }
     end
      else
        render json: {
          code: 400,
          success: false,
          message: "comment_id is required field.",
          data: nil
        }
      end
     end


  else
    render json: {
      code:400,
      success: false,
      message: "The operation has been blocked!",
      data: nil
    }
  end
else
  render json: {
    code: 400,
    success: false,
    message: 'event_id and is_reply fields are required.',
    data: nil
  }
end
end

  api :POST, '/api/v1/event/comments', 'Get list of event based comments'
  param :event_id, :number, :desc => "Event ID", :required => true


   def comments
    @event = ChildEvent.find(params[:event_id])
     @comments = []
    ## if event is not blocked by request user
    if !blocked_event?(request_user, @event)
      @event.comments.each do |comment|
        @replies = []
        @empty = []
        comment_modified = {
          "id" =>  comment.id,
          "comment" => comment.comment,
          "user_id" => comment.user_id,
          "event_id" => comment.event_id,
          "created_at" => comment.created_at,
          "updated_at" => comment.updated_at,
          "from" => get_full_name(comment.user),
          "user_avatar" => comment.user.avatar,
          "read_at" => comment.read_at,
          "reader_id" => comment.reader_id,
          "is_host" => is_host?(comment.user,  @event)
        }
        comment.replies.each do |reply|
          @replies << {
          "id" => reply.id,
          "comment" => reply.msg,
          "user_id" => reply.user_id,
          "from" => get_full_name(reply.user),
          "avatar" => reply.user.avatar,
          "created_at" => reply.created_at,
          "reply_to" =>  if !reply.reply_to_user.blank?  then reply.reply_to_user else @empty end,
          "is_host" => is_host?(reply.user,  @event)
        }
      end
        @comments << {
          "comment" => comment_modified,
          "replies" => @replies
        }
      end
    else
      blocked_at = request_user.user_settings.where(resource: @event).first.created_at
      @comments = @event.comments.where(['created_at < ?', blocked_at])
    end

    render json: {
     code: 200,
     success: true,
     message: '',
     data:  {
        comments:  @comments
     }
  }
   end


  api :get, '/api/v1/event/get-commented-events', 'Get comment events'

   def get_commented_events
     @events = []
     @response = []
     @commented_events = request_user.comments.each do |comment|
       @events.push(comment.child_event)
     end#each
     @events.uniq.each do |e|
      last_comment = e.comments.order(created_at: 'DESC').first
      last_comment_modified = {
       "id" => last_comment.id,
       "comment" => last_comment.comment,
       "user_id" => last_comment.user_id,
       "event_id" => last_comment.child_event_id,
       "created_at" => last_comment.created_at,
       "updated_at" => last_comment.updated_at,
       "from" => get_full_name(last_comment.user),
       "user_avatar" => last_comment.user.avatar,
       "read_at" => last_comment.read_at,
       "reader_id" => last_comment.reader_id
      }

      @response << {
        'id' => e.id,
        'name' => e.name,
        'creator_name' => get_full_name(e.user),
        'creator_id' => e.user.id,
        'creator_image' => e.user.avatar,
        "is_blocked" => blocked_event?(request_user, e),
        "is_mute" => event_chat_muted?(request_user, e),
        "last_comment" => last_comment_modified,
        "unread_count" => get_unread_comments_count(e)
       }
     end #each

     render json:  {
       code: 200,
       success: true,
       message: '',
       data: {
         commented_events: @response
       }
     }
   end

  api :POST, '/api/v1/event/delete-event-comments', 'Delete Comment Events'
  param :event_id, :number, :desc => "Event ID", :required => true

   def delete_event_comments
     if !params[:event_id].blank?
       event = ChildEvent.find(params[:event_id])
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

  api :POST, '/api/v1/event/mark-as-read', 'To mark as read'
  param :event_id, :number, :desc => "Event ID", :required => true

def mark_as_read
  if !params[:event_id].blank?
    event = ChildEvent.find(params[:event_id])
    if event.comments.unread.update_all(read_at: Time.zone.now, reader_id: request_user.id)
      render json: {
        code: 200,
        success: true,
        message: "Comment read successfully.",
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "Comment read failed.",
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
