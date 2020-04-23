class Admin::ChatController < Admin::AdminMasterController
   require 'pubnub'
    def initialize
      @pubnub_publish_key = "pub-c-c3a12388-ebea-4a9c-8d8f-ffd650226bab"
      @pubnub_subscribe_key = "sub-c-6c531956-09d6-11ea-aa30-ead0b8c5d242"
    end
 
 
 @@my_callback = lambda { |envelope|
 puts envelope.status
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
gon.sub_key = @pubnub_subscribe_key
gon.pub_key = @pubnub_publish_key
gon.channel = @channel
gon.uuid = @username



@pubnub.history(
   channel: @channel,
   count: 20,
   http_sync: true
) do |envelope|
 @history_messages = envelope.result[:data][:messages]
end

end

def send_message
  @pubnub = Pubnub.new(
  publish_key: "pub-c-c3a12388-ebea-4a9c-8d8f-ffd650226bab",
  subscribe_key: "sub-c-6c531956-09d6-11ea-aa30-ead0b8c5d242",
  uuid: params[:username]
 )
@pubnub.publish(
   channel: params[:current_channel],
   message: {:sender => params[:current_username], :message => params[:message]},
   callback: @@my_callback
)
render json: @@my_callback
end

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
