class Admin::FriendshipsController < Admin::AdminMasterController
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def send_request
    @friend = User.find(params[:id])
    @sender = current_user
    if(request_status(@sender,@friend) == nil)
      @friend_request = @sender.friend_requests.new(friend: @friend)
      @friend_request.status = "pending"
    if @friend_request.save
      #create_activity("sent friend request to #{@friend.first_name + ' ' + @friend.last_name}", @friend_request, "FriendRequest", '','', 'post')
     if @notification = Notification.create(recipient: @friend, actor: @sender, action: User.get_full_name(@sender) + " sent you a friend request", notifiable: @friend_request, url: '/admin/friend-requests', notification_type: 'web')  
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
      )
      @pubnub.publish(
        channel: [@friend.id.to_s],
        message: { 
          action: @notification.action,
          avatar: @sender.avatar,
          time: time_ago_in_words(@notification.created_at),
          notification_url: "/admin/friend-requests"
         }
      ) do |envelope|
        puts envelope.status
      end
    end ##notification create

      render json:  {
        message: "Friend request sent.",
        success: true
      }
    else
      render json:  {
        message: "Friend request sending failed.",
        success: false
      }
  end
else
  render json:  {
    message: "Request has already been sent.",
    check: request_status(@sender,@friend),
    success: false
  }
end
end

def check_request
   sender = current_user
   friend = User.find(params[:id]);
   status = request_status(sender,friend)
   render json: {
     success: true,
     status: status
   }
end

def friend_requests
  @requests = User.friend_requests(current_user)
  #@outgoing = current_user.friend_requests
  render :friend_requests  
end

def accept_request
  request = FriendRequest.find(params[:id])
  request.status = 'accepted'
  if request.save
    create_activity("accepted friend request of #{request.user.first_name + ' ' + request.user.last_name}", request, "FriendRequest", '','', 'get', 'accept_request')
    new_request = FriendRequest.new
    new_request.user_id = request.friend_id
    new_request.friend_id = request.user_id
    new_request.status = 'accepted'
    if new_request.save
       # send notifiation as well
     if @notification = Notification.create(recipient: request.user, actor: current_user, action: User.get_full_name(current_user) + " accepted your friend request", notifiable: request, url: '/admin/my-friends', notification_type: 'web')
     flash[:notice] = "Friend request accepted."
     #publish notification to pubnub as well
     @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
      )
     @pubnub.publish(
      channel: [request.user.id.to_s],
      message: { 
        action: @notification.action,
        avatar: current_user.avatar,
        time: time_ago_in_words(@notification.created_at),
        notification_url: "/admin/my-friends"
       }
    ) do |envelope|
      puts envelope.status
    end
  end # notification create

     redirect_to admin_my_friends_path

    else
      flash[:alert_danger] = "Friend request acceptance failed."
      redirect_to admin_my_friends_path
    end
  end
end

def my_friends
  render :index
end

end
