class Api::V1::FollowsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
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
     @following = User.find(params[:following_id])
     check = Follow.where(following_id: params[:following_id]).where(user_id: request_user.id)
     if check.blank?
     if fr = Follow.create!(following_id: params[:following_id], user_id: request_user.id,status: true)
      create_activity(request_user,"followed #{get_full_name(@following)}", fr, 'Follow', '', '', 'post', 'follow')
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
      if @notification = Notification.create(recipient: @following, actor: request_user, action: get_full_name(request_user) + " followed you", notifiable: fr, url: '#', notification_type: 'web', action_type: 'add_to_wallet')  

       #publish web channel
       @pubnub.publish(
         channel: [@following.id.to_s],
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
          if @notification = Notification.create(recipient: friend, actor: request_user, action: "Your friend " + get_full_name(request_user) + " followed #{get_full_name(@following)}.", notifiable: fr, url: "#", notification_type: 'mobile', action_type: 'add_to_wallet')  
            @push_channel = "event" #encrypt later
            @current_push_token = @pubnub.add_channels_to_push(
               push_token: friend.profile.device_token,
               type: 'gcm',
               add: friend.profile.device_token
               ).value
    
             payload = { 
              "pn_gcm":{
               "notification":{
                 "title": get_full_name(request_user),
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
                "body": ''   
               }
              }
             }
             @pubnub.publish(
              channel: friend.profile.device_token,
              message: payload
              ) do |envelope|
                  puts envelope.status
             end
          end ##notification create
        end #each
      end #if not blank

       render json: {
       code: 200,
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
      end # if fr crate
     else
      render json: {
        code: 400,
        success:false,
        message: "Already following.",
        data: nil
      }
     end
    end
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
    @follow = Follow.where(:following_id => params[:following_id]).where(:user_id => request_user.id).first
    if @follow && @follow.destroy
      @following = User.find(params[:following_id])
     # create_activity(request_user, "unfollowed #{get_full_name(@following)}", @follow, 'Follow', '', '', 'post','unfollow')
      if @notification = Notification.create(recipient: @following, actor: request_user, action: get_full_name(request_user) + " unfollowed you", notifiable: @follow, url: '#', notification_type: 'web')  
       #publish to web channel
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
       @pubnub.publish(
         channel: [@following.id.to_s],
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
    @followers = request_user.followers
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
           followers: @followers
       }
    }
  end

  def followings
    @followings = [] 
    request_user.followings.each do |following|
      @followings << {
        "business" => get_business_object(following),
        "friends_follwoing_count" =>  get_following_friends_count(following)
      }
    end#each

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
           followings: @followings
       }
    }
  end

#   def accept_request
#      fr = Follow.where(user_id: params[:user_id]).where(following_id: request_user.id).first
#      if fr.update(:status => true)
#       fr.follow_request.destroy
#       if @notification = Notification.create(recipient: fr.follower, actor: request_user, action: get_full_name(request_user) + " accepted your follow request", notifiable: fr, url: '/admin/follow-requests', notification_type: 'mobile')  
#         @pubnub = Pubnub.new(
#         publish_key: ENV['PUBLISH_KEY'],
#         subscribe_key: ENV['SUBSCRIBE_KEY']
#         )
  
#         @current_push_token = @pubnub.add_channels_to_push(
#           push_token: fr.follower.profile.device_token,
#           type: 'gcm',
#           add: fr.follower.profile.device_token
#           ).value
  
#         payload = { 
#         "pn_gcm":{
#           "notification":{
#             "title": @notification.action
#           },
#           "type": @notification.notifiable_type
#         }
#       }
  
#         @pubnub.publish(
#          channel: [fr.follower.profile.device_token],
#          message: payload
#           ) do |envelope|
#             puts envelope.status
#         end
#       end ##notification create
#      render json: {
#         code: 200,
#         success:true,
#         message: "Accepted successfully.",
#         data: nil
#       }
#      else
#        render json: {
#         code: 400,
#         success:false,
#         message: "Accept failed.",
#         data: nil
#        }
#       end
# end # func

   def requests_list
     follow_requests = request_user.follow_requests
    render json: {
          code: 200, 
          success: true,
          message: '',
          data: {
            requests: follow_requests
        }
      }
   end

   def remove_request
     if !params[:request_id].blank?
       fr = FollowRequest.find(params[:request_id])
       if fr.destroy
       # create_activity(request_user,"removed request of #{get_full_name(fr.sender)}", fr, 'Follow', '', '', 'post')
        render json: {
        code: 200,
        success: true,
        message: "Request deleted successfully.",
        data: nil
      }
       else
        render json: {
        code: 400,
        success: false,
        message: "Request deletion failed.",
        data: nil
      }
       end
     else
      render json: {
        code: 400,
        success: false,
        message: "Request id is required.",
        data: nil
      }
     end
   end

   def remove_follower
    if !params[:user_id].blank?
      if fr = Follow.where(user_id: params[:user_id]).where(following_id: request_user.id).first.destroy
       # create_activity(request_user, "removed #{get_full_name(User.find(params[:user_id]))} from your followers", fr, 'Follow', '', '', 'post')
        render json: {
          code: 200,
          success: true,
          message: "Follower removed successfully.",
          data: nil
        }
      else
        render json: {
          code: 400,
          success: false,
          message: "Follower removal failed.",
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "User id is required.",
        data: nil
      }
    end
   end

   def suggest_businesses
    @businesses_suggestions = []
   
   if !request_user.friends.blank?
     request_user.friends.each do |friend|
      # 1. If an ambassador is my friend his/her business should be in my business suggestion.
         if friend.profile.is_ambassador ==  true
            friend.ambassador_businesses.each do |business|
              @businesses_suggestions.push(business)
            end
         end #if
         # 2. businesses who are being followed by my friends`
         friend.followings.each do |follwoing|
           @businesses_suggestions.push(follwoing)
         end #each
         # 3. Businesses followed by my friends of friends.
         friend.friends.each do |friend|
           friend.followings.each do |following|
               @businesses_suggestions.push(following)
           end#each
         end #each
     end #each
   end #if

 #if there are no users based on the above principle then suggest poineer user upto 7 
  if @businesses_suggestions.blank? || @businesses_suggestions.size < 30
    if User.web_users.size > 30
      User.web_users[1..30].each do |user|
       @businesses_suggestions.push(user)
     end#each
     else
      User.web_users.each do |user|
       @businesses_suggestions.push(user)
     end#each
     end  
  end

# I want to see that how many of my friends are already following a suggested business
# So that I can see the business credibility.
 @businesses = []
 @friends_following = []
   @businesses_suggestions.uniq.each do |business|
    if not_me?(business) && !is_my_following?(business)
      @businesses << {
        "business" => get_business_object(business),
        "friends_follwoing_count" =>  get_following_friends_count(business)
      }
    end #if       
   end #each

  render json: {
    code: 200,
    success: true,
    message: "",
    data:  {
      suggested_businesses: @businesses,
      user: request_user
    }
  }
  end

  private
  
  def get_following_friends_count(business)
    friends_following = []
     request_user.friends.each do |friend|
       if business.followers.include? friend
         friends_following.push(friend)
       end# each 
    end#each

    friends_following.size
  end

 
 

end# class