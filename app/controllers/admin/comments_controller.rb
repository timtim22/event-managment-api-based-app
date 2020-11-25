class Admin::CommentsController < Admin::AdminMasterController
  require 'pubnub'

  def create
    @event = Event.find(params[:event_id])
    @comment = @event.comments.new()
    @comment.user = current_user
    @comment.user_avatar = current_user.avatar
    @comment.from = get_full_name(current_user)
    @comment.comment = params[:comment]
    if @comment.save
      # Shoot notifications to users who commented on an event
      #create_activity("posted a comment", @comment, "Comment", admin_event_path(@event),@event.name, 'post')
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )

          @channel = "event" #encrypt later
          users_array = []
          Comment.all.each do |comment|
          if comment.user != current_user
            users_array.push(comment.user.id)
          end #if
          end ##each
          users_array.uniq.each do |id|
          user = User.find(id)
          #setting is applicable
          if user.all_chat_notifications_setting.is_on == true && user.event_notifications_setting.is_on == true && !blocked_event?(user, @event) && !event_chat_muted?(user,@event)


          if @notification = Notification.create(recipient: user, actor: current_user, action: get_full_name(current_user) + " posted a new comment on event '#{@event.name}'.", notifiable: @comment, resource: @comment, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: 'post_comment_web')

          @current_push_token = @pubnub.add_channels_to_push(
           push_token: user.profile.device_token,
           type: 'gcm',
           add: user.profile.device_token
           ).value

           payload = {
            "pn_gcm":{
             "notification":{
               "title": @event.name,
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
              "body": @comment.comment
             }
            }
           }

         @pubnub.publish(
           channel: user.profile.device_token,
           message: payload
           ) do |envelope|
               puts envelope.status
          end
         end # notificatiob end

        end #all chat and event chat true
        end
       redirect_to admin_event_path(@event), :notice => "Comment successfully posted."
    else
      flash[:form_errors] = @comment.errors.full_messages
      redirect_to admin_event_path(@event)
    end
   end
end
