class Api::V1::FriendshipsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  
  def initialize
    @request_data = {}
  end
  
  def send_request
    @friend = User.find(params[:friend_id])
    @sender = request_user
    if(request_status(@sender,@friend) == false)
    @friend_request = @sender.friend_requests.new(friend: @friend)
    @friend_request.status = "pending"
    if @friend_request.save
      create_activity("sent friend request to #{User.get_full_name(@friend)}", @friend_request, 'FriendRequest', '', '', 'post')
      if @notification = Notification.create(recipient: @friend, actor: @sender, action: User.get_full_name(@sender) + " sent you a friend request", notifiable: @friend_request, url: '/admin/friend-requests', notification_type: 'mobile', action_type: 'send_request')  
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
          "notification":{
            "title": User.get_full_name(@friend),
            "body": @notification.action
          },
          data: {
            "id": @notification.id,
            "actor_id": @notification.actor_id,
            "actor_image": @notification.actor.avatar.url,
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
         channel: [@friend.device_token],
         message: payload
          ) do |envelope|
            puts envelope.status
        end
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
      message: "Request has already been sent.",
      data:nil
    }
  
end
end

def check_request
   sender = request_user
   friend = User.find(params[:friend_id]);
   status = request_status(sender,friend)
   render json: {
     code: 200,
     success: true,
     message: '',
     data: {
       status: status
     }
   }
end

def friend_requests
  requests = User.friend_requests(request_user)
  @requests = []
  requests.each do |request|
    sender  = User.find(request.user_id)
    @requests << {
      "id": request.id,
      "first_name" => sender.first_name,
      "last_name" => sender.last_name,
      "avatar" => sender.avatar.url,
      "status" => request.status,
      "user_id" => request.user_id,
      "friend_id" => request.friend_id,
      'mutual_friends_count' =>  sender.friends.size
    }
  end
  render json: {
    code: 200,
    success: true,
    message: '',
    data: {
      requests: @requests
    }
  }  
end

def accept_request
  request = FriendRequest.find(params[:request_id])
  request.status = 'accepted'
  if request.save
    new_request = FriendRequest.new
    new_request.user_id = request.friend_id
    new_request.friend_id = request.user_id
    new_request.status = 'accepted'
    if new_request.save
      create_activity("accepted friend request of #{User.get_full_name(request.user)}", request, 'FriendRequest', '', '', 'post')
      #clear friend request notifcation on accpet
      @notification =  Notification.where(notifiable_id: request.id).where(notifiable_type: 'FriendRequest').first.destroy
     
      
      if @notification = Notification.create(recipient: request.user, actor: request_user, action: User.get_full_name(request_user) + " accepted your friend request", notifiable: request, url: '/admin/my-friends', notification_type: 'mobile', action_type: 'accept_request')  
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
                "title": User.get_full_name(request_user),
                "body": @notification.action
              },
              data: {
                "id": @notification.id,
                "actor_id": @notification.actor_id,
                "actor_image": @notification.actor.avatar.url,
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
         channel: [request.user.device_token],
         message: payload
          ) do |envelope|
            puts envelope.status
        end
      end ##notification create
     render json: {
       code: 200,
       success: true,
       message: "Friend request accepted.",
       data:nil
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
end

def remove_request
  friend_request = FriendRequest.where(friend_id: request_user.id).where(user_id: params[:user_id]).first
   #clear friend request notifcation on remove
   @notification =  Notification.where(notifiable_id: friend_request.id).where(notifiable_type: 'FriendRequest').first.destroy
  if friend_request.destroy
    
    create_activity("removed friend request of #{User.get_full_name(friend_request.user)}", friend_request, 'FriendRequest', '', '', 'post')
    
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

def my_friends
  requests = FriendRequest.where(user_id: request_user.id).where(status: 'accepted')
  friends_array = []
  requests.each do |request|
    @friend = User.find(request.friend_id)
    friend = {}
    friend['friend'] = @friend
    friend['friends_count'] = @friend.friends.size
    friends_array.push(friend)
  end
  render json: {
    code: 200,
    success: true,
    message: '',
    data: {
      friends: friends_array
    }
}.to_json
end

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
    #create_activity("removed #{User.get_full_name(User.find(params[:friend_id]))} from your friend list", @request, 'FriendRequest', '', '', 'post')
    render json: {
      code: 200, 
      success: true,
      message: "Unfriend successfully.",
      data:nil
    }
  end # main  
end# #func

def suggest_friends
  @friends_suggestions = []
  # 1. Friends of my friends
 if !request_user.friends.blank?
  request_user.friends.each do |friend|
    friend.friends.each do |s_friend|
      if not_me?(s_friend) == true && is_my_friend?(s_friend) == false
        @friends_suggestions.push(s_friend)
      end
    end
  end #each
end #if

  # 2. Poeple who are attending same event as logged in user
  if !request_user.events_to_attend.blank? 
       request_user.events_to_attend.each do  |event|
       event.going_users.each do |user|
        if not_me?(user) == true && is_my_friend?(user) == false
          @friends_suggestions.push(user)
        end# if
       end #each
      end #each
    end #if
    
    # 3. Poeple who are interested in same event as logged in user
   if !request_user.interested_in_events.blank?
       request_user.interested_in_events.each do |event|
       event.interested_users.each do |user|
         if not_me?(user) == true && is_my_friend?(user) == false
          @friends_suggestions.push(user)
        end#if
       end #each
    end#each
 end #if

 # 4. People who has same passes in their wallet as logged in user
  if !request_user.owned_passes.blank?
      request_user.owned_passes.each do |pass|
        #users who added it to wallet
        pass.owners.each do |owner|
         if not_me?(owner) == true && is_my_friend?(owner) == false
          @friends_suggestions.push(owner)
         end#if
        end
      end #each
  end#if
  
  # 5. People who has same special offers in their wallet as logged in user
  if !request_user.owned_special_offers.blank?
    request_user.owned_special_offers.each do |special_offer|
      #users who added it to wallet
      special_offer.owners.each do |owner|
       if not_me?(owner) == true && is_my_friend?(owner) == false
        @friends_suggestions.push(owner)
       end#if
      end
    end #each
end#if

#  6. people who are going to attend same competition.
 if !request_user.competitions_to_attend.blank? 
  request_user.competitions_to_attend.each do  |competition|
    competition.participants.each do |participant|
   if not_me?(participant) == true && is_my_friend?(participant) == false
     @friends_suggestions.push(participant)
   end# if
  end #each
 end #each
end #if

#if there are no users based on the above principle then suggest poineer user upto 7 
if @friends_suggestions.blank?
  User.where(id: [1..7]).each do |user|
  if not_me?(user)
    @friends_suggestions.push(user)
  end #if 
  end#each
end

 @all_suggessions = [] 
 @friends_suggestions.each do  |user| 
   @all_suggessions << {
     user:  user,
     mutual_friends_count: user.friends.size,
     is_request_sent: request_status(request_user, user)
    }
  end #each 
 

 render json: {
   code: 200,
   success: true,
   message: "",
   data:  {
     suggested_friends: @all_suggessions
   }
 }
  
 end #func


  
  private
  
  
end
