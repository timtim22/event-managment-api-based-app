class Admin::FollowsController < Admin::AdminMasterController
  before_action :require_signin
  # Send follow request
  def follow
    if params[:following_id].blank? == true
      render json: {
        code: 400,
        success: false,
        message: "Following id is required.",
        data: nil
      }
    else
      check = FollowRequest.where(sender_id: current_user.id).where(recipient_id: params[:following_id]).first
      if check == nil
        follow_request = FollowRequest.new
        follow_request.sender_id = current_user.id
        follow_request.recipient_id = params[:following_id]
        follow_request.sender_avatar = current_user.avatar
        follow_request.sender_name = get_full_name(current_user)
        if follow_request.save
        @following = User.find(params[:following_id])
        create_activity("sent a follow request to #{@following.first_name ' ' + @following.last_name}", follow_request, "FollowRequest", '','', 'post')
        # fr => follow relationship
        fr = Follow.create!(following_id: params[:following_id], user_id: current_user.id, follow_request_id: follow_request.id)
        if @notification = Notification.create(recipient: @following, actor: current_user, action: get_full_name(current_user) + " wants to follow you", notifiable: fr, url: '/admin/follow-requests', notification_type: 'mobile_web')  
         @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
         )
        
         @current_push_token = @pubnub.add_channels_to_push(
           push_token: @following.device_token,
           type: 'gcm',
           add: @following.device_token
           ).value
        
         payload = { 
         "pn_gcm":{
           "notification":{
             "title": @notification.action
           },
           "type": @notification.notifiable_type
         }
        }

        #publish both to mobile and web channel

        @pubnub.publish(
          channel: [@event.user.id.to_s],
          message: { 
            action: @notification.action,
            avatar: current_user.avatar,
            time: time_ago_in_words(@notification.created_at),
            notification_url: @notification.url
           }
        ) do |envelope|
          puts envelope.status
        end
        #mobile
         @pubnub.publish(
          channel: [@following.device_token],
          message: payload
           ) do |envelope|
             puts envelope.status
         end
        end ##notification create

       render json: {
        code: 400,
        success:true,
        message: "followed successfully.",
        data: nil
        }
        else
        render json: {
        code: 400,
        success:false,
        message: "follow failed.",
        data: nil
        }
        end
        else
          render json: {
            code: 400,
            success:false,
            message: "Already following.",
            data: nil
          }
        end# check if
    end # id require if
  end# func


  def unfollow
    if params[:following_id].blank? == true
      render json: {
        code: 400,
        success: false,
        message: "Following id is required.",
        data: nil
      }
    else
    if current_user.following_relationships.find_by(following_id: params[:following_id]).destroy
      render json: {
        code: 200,
        success:true,
        message: "Unfollowed successfully.",
        data: nil
      }
     else
       render json: {
        code: 400,
        success:false,
        message: "Unfollow failed.",
        data: nil
      }
    end
  end
end

  def followers
    @followers = current_user.followers
  end

  def followings
    @followings = current_user.followings
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
           followings: @followings
       }
    }
  end

  def accept_request
     fr = Follow.where(user_id: params[:user_id]).where(following_id: current_user.id).first
     if fr.update(:status => true)
      fr.follow_request.destroy
      if @notification = Notification.create(recipient: fr.follower, actor: current_user, action: get_full_name(current_user) + " accepted your follow request", notifiable: fr, url: '/admin/follow-requests', notification_type: 'mobile')  
        @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
  
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: fr.follower.profile.device_token,
          type: 'gcm',
          add: fr.follower.profile.device_token
          ).value
  
        payload = { 
        "pn_gcm":{
          "notification":{
            "title": @notification.action
          },
          "type": @notification.notifiable_type
        }
      }
  
        @pubnub.publish(
         channel: [fr.follower.profile.device_token],
         message: payload
          ) do |envelope|
            puts envelope.status
        end
      end ##notification create
      flash[:alert_success] = "Follow request accepted."
      redirect_to admin_my_followers_path
     else
       render json: {
        code: 400,
        success:false,
        message: "Accept failed.",
        data: nil
       }
      end
end # func

   def requests_list
     @requests = current_user.follow_requests
      render :follow_requests
   end

end# class
