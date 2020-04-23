class Admin::CommentsController < Admin::AdminMasterController
  require 'pubnub'

  def create
    @event = Event.find(params[:event_id])
    @comment = @event.comments.new()
    @comment.user = current_user
    @comment.user_avatar = current_user.avatar.url
    @comment.from = User.get_full_name(current_user)  
    @comment.comment = params[:comment]
    if @comment.save
      # Shoot notifications to users who commented on an event
      create_activity("posted a comment", @comment, "Comment", admin_event_path(@event),@event.name, 'post')
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY'],
        uuid: @comment.user.first_name
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
          @setting = EventSetting.where(event_id: @event.id).where(user_id: user.id)
          if !@setting.blank? && !@setting.mute_notifications 
          if @notification = Notification.create(recipient: user, actor: current_user, action: User.get_full_name(current_user) + " posted a new comment on event '#{@event.name}'.", notifiable: @comment, url: "/admin/events/#{@event.id}", notification_type: 'mobile') 
         
          @current_push_token = @pubnub.add_channels_to_push(
           push_token: user.device_token,
           type: 'gcm',
           add: user.device_token
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
              "actor_image": @notification.actor.avatar.url,
              "notifiable_id": @notification.notifiable_id,
              "notifiable_type": @notification.notifiable_type,
              "action": @notification.action,
              "created_at": @notification.created_at,
              "body": @comment.comment  
             }
            }
           }
          
         @pubnub.publish(
           channel: user.device_token,
           message: payload
           ) do |envelope|
               puts envelope.status
          end
         end # notificatiob end
         end #setting 
        end
       redirect_to admin_event_path(@event), :notice => "Comment successfully posted." 
    else 
      flash[:form_errors] = @comment.errors.full_messages
      redirect_to admin_event_path(@event)
    end 
   end
end
