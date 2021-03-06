class Api::V1::Friendship::FriendshipsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def initialize
    @request_data = {}
  end

  api :POST, '/api/v1/friendship/send-request', 'To send friend request to a user'
  param :friend_id, :number, :desc => "Friend ID", :required => true


  def send_request
    if !params[:friend_id].blank?
     @friend = User.find(params[:friend_id])
     @sender = request_user
    if(request_status(@sender,@friend)['status'] == false)
    @friend_request = @sender.friend_requests.new(friend: @friend)
    @friend_request.status = "pending"
    if @friend_request.save
      #create_activity("sent friend request to #{get_full_name(@friend)}", @friend_request, 'FriendRequest', '', '', 'post', 'send_friend_request')
     
      if notification = Notification.create(recipient: @friend, actor: @sender, action: get_full_name(@sender) + " sent you a friend request", notifiable: @friend_request, resource: @friend_request, url: '/admin/friend-requests', notification_type: 'mobile', action_type: 'send_request')

      if !mute_push_notification?(@friend)

        @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )

        @current_push_token = @pubnub.add_channels_to_push(
          push_token: @friend.device_token,
          type: 'gcm',
          add: @friend.device_token
          ).value

        payload = {
        "pn_gcm":{
          "notification": {
            "title": get_full_name(@friend),
            "body": notification.action
          },
          data: {

            "id": notification.id,
            "friend_name": get_full_name(notification.resource.user),
            "friend_id": notification.resource.user.id,
            "request_id": notification.resource.id,
            "mutual_friends_count": get_mutual_friends(request_user, @friend).size,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?
           }
        }
      }

        @pubnub.publish(
         channel: [@friend.device_token],
         message: payload
          ) do |envelope|
            puts envelope.status
        end
      end #setting
      end ##notification create
      render json:  {
        code: 200,
        success: true,
        message: "Friend request sent.",
        data:nil
      }
    else
      render json:  {
        code: 400,
        success: false,
        message: "Friend request sending failed.",
        data:nil
      }
  end
else
    render json:  {
      code: 400,
      success: false,
      message: request_status(@sender, @friend)['message'],
      data:nil
   }
end
else
  render json:  {
    code: 400,
    success: false,
    message: "friend_id is required fields.",
    data:nil
 }
end
end

# api :POST, '/api/v1/check-request', 'check request status whether sent or not'
# param :friend_id, :number, :desc => "Friend ID", :required => true

# def check_request
#    sender = request_user
#    friend = User.find(params[:friend_id]);
#    status = request_status(sender,friend)
#    render json: {
#      code: 200,
#      success: true,
#      message: '',
#      data: {
#        status: status
#      }
#    }
# end

api :GET, '/api/v1/friendship/friend-requests', 'To view all friend requests - Token is reqiured'

def friend_requests
  requests = User.friend_requests(request_user)
  @requests = []
  requests.each do |request|
    sender  = User.find(request.user_id)
    @requests << {
      "id": request.id,
      "first_name" => sender.profile.first_name,
      "last_name" => sender.profile.last_name,
      "avatar" => sender.avatar,
      "status" => request.status,
      "user_id" => request.user_id,
      "friend_id" => request.friend_id,
      'mutual_friends_count' =>  get_mutual_friends(request_user, request.user).size,
      'is_ambassador' => is_ambassador?(request.user)
    }
  end
  render json: {
    code: 200,
    success: true,
    message: '',
    data: {
      requests: paginate_array(@requests)
    }
  }
end

  api :POST, '/api/v1/friendship/accept-request', 'To accpet a friend request'
  param :request_id, :number, :desc => "accept ID", :required => true

def accept_request
  if !params[:request_id].blank?
  request = FriendRequest.find(params[:request_id])
  request.status = 'accepted'
  if request.save
    new_request = FriendRequest.new
    new_request.user_id = request.friend_id
    new_request.friend_id = request.user_id
    new_request.status = 'accepted'
    if new_request.save
      create_activity(request_user, "become friend", request, 'FriendRequest', '', '', 'post', 'accept_friend_request')
      #clear friend request notifcation on accpet
      @notification =  Notification.where(notifiable_id: request.id).where(notifiable_type: 'FriendRequest').first
      if !@notification.blank?
       @notification.destroy
      end



      if notification = Notification.create(recipient: request.user, actor: request_user, action: get_full_name(request_user) + " accepted your friend request", notifiable: request, resource: request, url: '/admin/my-friends', notification_type: 'mobile', action_type: 'accept_request')
       
     if !mute_push_notification?(request.user)

        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
        )
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: request.user.device_token,
          type: 'gcm',
          add: request.user.device_token
          ).value

          payload = {
            "pn_gcm":{
              "notification":{
                "title": get_full_name(request_user),
                "body": notification.action
              },
              data: {
                "id": notification.id,
                "friend_name": get_full_name(notification.resource.friend),
                "friend_id": notification.resource.friend.id,
                "mutual_friends_count": get_mutual_friends(request_user, notification.resource.friend).size,
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?
              }
            }
          }

        @pubnub.publish(
         channel: [request.user.device_token],
         message: payload
          ) do |envelope|
            puts envelope.status
        end
      end #setting
      end ##notification create
     render json: {
       code: 200,
       success: true,
       message: "Friend request accepted.",
       data: {
        friend_id: request.user.id,
        first_name: request.user.profile.first_name,
        last_name: request.user.profile.last_name,
        avatar: request.user.avatar,
        mutual_friends_count: get_mutual_friends(request_user, request.user).size,
        is_ambassador: is_ambassador?(request.user)

       }
     }
    else
      render json: {
        code: 400,
        success: false,
        message: "Friend request acceptance failed.",
        data:nil
      }
    end
  end
else
  render json: {
    code: 400,
    success: false,
    message: "request_id is required field.",
    data: nil
  }
end
end

  api :POST, '/api/v1/friendship/remove-request', 'To remove/delete friend request'
  param :user_id, :number, :desc => "User ID", :required => true

def remove_request
  friend_request = FriendRequest.where(friend_id: request_user.id).where(user_id: params[:user_id]).first
   #clear friend request notifcation on remove
   @notification =  Notification.where(notifiable_id: friend_request.id).where(notifiable_type: 'FriendRequest').first.destroy
  if friend_request.destroy

    #create_activity(request_user, "removed friend request of #{get_full_name(friend_request.user)}", friend_request, 'FriendRequest', '', '', 'post', 'remove_friend_request')

    render json: {
      code: 200,
      success: true,
      message: "Friend request removed successfully.",
      data: nil
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "Friend request removal failed.",
      data: nil
    }
  end
end

  # api :GET, '/api/v1/friendship/my-friends', 'To view all your friends - Token is required'
def my_friends
  requests = FriendRequest.where(user_id: request_user.id).where(status: 'accepted')
  friends_array = []
  requests.each do |request|
    @friend = User.find(request.friend_id)
    friend = {}
    friend['friend'] = get_user_object(@friend)
    friend['friends_count'] = get_mutual_friends(request_user, @friend).size
    friend['is_ambassador'] = is_ambassador?(@friend)
    friends_array.push(friend)
  end
  render json: {
    code: 200,
    success: true,
    message: '',
    data: {
      friends: paginate_array(friends_array)
    }
}.to_json
end

  api :POST, '/api/v1/friendship/remove-friend', 'To remove a friend'
  param :friend_id, :number, :desc => "Friend ID", :required => true

def remove_friend
  #remove bi directional friendship
  @requests = FriendRequest.where(user_id: request_user.id).where(friend_id: params[:friend_id]).where(status: 'accepted').or(FriendRequest.where(friend_id: request_user.id).where(user_id: params[:friend_id]).where(status: 'accepted'))
   if @requests.blank?
    render json: {
      code: 400,
      success: false,
      message: "No such friend found.",
      data:nil
   }
   else
    @requests.destroy_all
    #create activity
    @request = FriendRequest.find_by(friend_id: params[:friend_id])
    #create_activity("removed #{get_full_name(User.find(params[:friend_id]))} from your friend list", @request, 'FriendRequest', '', '', 'post')
    render json: {
      code: 200,
      success: true,
      message: "Unfriend successfully.",
      data:nil
    }
  end # main
end# #func

  api :GET, '/api/v1/friendship/suggest-friends', 'To View all suggest friends'

def suggest_friends
  @friends_suggestions = []
  # 1. Friends of my friends
 if !request_user.friends.blank?
  request_user.friends.each do |friend|
    friend.friends.each do |s_friend|
     @friends_suggestions.push(s_friend)
    end
  end #each
end #if

  # 2. Poeple who are attending same event as logged in user
  if !request_user.events_to_attend.blank?
       request_user.events_to_attend.each do  |event|
       event.going_users.each do |user|
        @friends_suggestions.push(user)
       end #each
      end #each
    end #if

    # 3. Poeple who are interested in same event as logged in user
   if !request_user.interested_in_events.blank?
       request_user.interested_in_events.each do |event|
       event.interested_users.each do |user|
          @friends_suggestions.push(user)
       end #each
    end#each
 end #if

 # 4. People who has same passes in their wallet as logged in user
  if !request_user.owned_passes.blank?
      request_user.owned_passes.each do |pass|
        #users who added it to wallet
        pass.owners.each do |owner|
          @friends_suggestions.push(owner)
        end
      end #each
  end#if

  # 5. People who has same special offers in their wallet as logged in user
  if !request_user.owned_special_offers.blank?
    request_user.owned_special_offers.each do |special_offer|
      #users who added it to wallet
      special_offer.owners.each do |owner|
        @friends_suggestions.push(owner)
      end
    end #each
end#if

#  6. people who are going to attend same competition.
 if !request_user.competitions_to_attend.blank?
  request_user.competitions_to_attend.each do  |competition|
    competition.participants.each do |participant|
  (participant)
     @friends_suggestions.push(participant)
  end #each
 end #each
end #if

#if there are no users based on the above principle then suggest poineer user upto 7
if @friends_suggestions.blank? || @friends_suggestions.size < 30
  if User.mobile_users.size > 30
   User.mobile_users[1..30].each do |user|
    @friends_suggestions.push(user)
  end#each
  else
   User.mobile_users.each do |user|
    @friends_suggestions.push(user)
  end#each
  end
end

 @all_suggessions = []
 @friends_suggestions.uniq.each do  |user|

  if not_me?(user) && !is_my_friend?(user) && !is_business?(user) && !friend_request_sent?(request_user, user)
    @all_suggessions << {
     user:  get_user_object(user),
     mutual_friends_count: get_mutual_friends(request_user, user).size,
     is_request_sent: request_status(request_user, user)
    }
  end#if
  end #each

 render json: {
   code: 200,
   success: true,
   message: "",
   data:  {
     suggested_friends: paginate_array(@all_suggessions)
   }
 }

 end #func

  api :POST, '/api/v1/friendship/get-friends-details', 'To get friend details'
  param :user_id, :number, :desc => "User ID", :required => true

 def get_friends_details
  if !params[:user_id].blank?
    details = []
    user = User.find(params[:user_id])
    if is_business?(user)
      followers = user.followers
      if !followers.blank?
       followers.each do |follower|
       details << {
           "id" => follower.id,
           "name" => get_full_name(follower),
           "avatar" => follower.avatar,
           "is_request_sent" => request_status(request_user, follower)["status"],
           "is_friend" => is_friend?(request_user, follower),
           "mutual_friends_count" => get_mutual_friends(request_user, follower).size,
           "is_my_following" => false,
           "roles" => get_user_role_names(follower),
           "is_self" =>  !not_me?(follower),
           "followers_count" => user.followings.size
         }
         end #each
      end #not empty
      else
       if params[:detail_type] == 'followings'
        followings = user.followings
        if !followings.blank?
         followings.each do |following|
        details << {
            "id" => following.id,
            "name" => get_full_name(following),
            "avatar" => following.avatar,
            "is_request_sent" => false,
            "is_friend" => false,
            "mutual_friends_count" => 0,
            "is_my_following" => is_my_following?(following),
            "roles" => get_user_role_names(following),
            "is_self" =>  !not_me?(following),
            "followers_count" => following.followers.size

          }
         end #each
       end #not empty
       else
         friends = user.friends
         if !friends.blank?
        friends.each do |friend|
        details << {
            "id" => friend.id,
            "name" => get_full_name(friend),
            "avatar" => friend.avatar,
            "is_request_sent" => request_status(request_user, friend)["status"],
            "is_friend" => is_friend?(request_user, friend),
            "mutual_friends_count" => get_mutual_friends(request_user, friend).size,
            "is_my_following" => false,
            "roles" => get_user_role_names(friend),
            "is_self" =>  !not_me?(friend),
            "followers_count" => friend.followings.size
          }
          end #each
        end #not empty
      end #if
    end


    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        details: paginate_array(details)
      }
    }
    else
      render json: {
      code: 400,
      success: false,
      message: 'user_id is required.',
      data: nil
    }
    end
end



end
