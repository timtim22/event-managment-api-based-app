class ChatsController < ApplicationController
    require 'pubnub'
     def initialize
       @pubnub_publish_key = ENV
       @pubnub_subscribe_key = "sub-c-6c531956-09d6-11ea-aa30-ead0b8c5d242"
     end
  
  
  @@my_callback = lambda { |envelope|
    render json: {
      status: envelope.status
    }
 }
 
 def index
 @channel = params[:channel]
 @username = params[:username]
 @history_messages = nil
 @pubnub = Pubnub.new(
   publish_key: "pub-c-c3a12388-ebea-4a9c-8d8f-ffd650226bab",
   subscribe_key: "sub-c-6c531956-09d6-11ea-aa30-ead0b8c5d242",
   uuid: @username
  )
# Only for passing it to JS on client side
#  gon.sub_key = @pubnub_subscribe_key
#  gon.pub_key = @pubnub_publish_key
#  gon.channel = @channel
#  gon.uuid = @username
 end
 
#  def send_message
#    @pubnub = Pubnub.new(
#    publish_key: "pub-c-c3a12388-ebea-4a9c-8d8f-ffd650226bab",
#    subscribe_key: "sub-c-6c531956-09d6-11ea-aa30-ead0b8c5d242",
#    uuid: params[:username]
#   )
#   pubnub.add_channels_to_push(push_token: params[:device_token] , type: 'gcm', add: params[:channel]).value


#  pn_gcm_payload = { a: 1, b: 2. c: 3 }
#  pn_mpns_payload = { a: 2, b: 3, c: 4 }
#  pn_apns_payload = { a: 3, b: 4, c: 5 }

# payload = {
#     'pn_gcm': pn_gcm_payload,
#     'pn_mpns': pn_mpns_payload,
#     'pn_apns': pn_apns_payload
# }
# pubnub.publish(
#   channel: params[:channel],
#   message: payload
#  )

#  end

#  @pubnub.history[]
#   channel: params[:channel],
#   count: 20,
#   http_sync: true
# ) do |envelope|
# @history_messages = envelope.result[:data][:messages]
# end

# end
 
 def unsubscribe
 @pubnub.unsubscribe(
    channel: params[:channel]
 ) 
 redirect_to root_url
 end
 
 def subscribe
   @pubnub.subscribe(
   channels: params[:channel]
   
 )
 render json: true
 end
 
 end
 

