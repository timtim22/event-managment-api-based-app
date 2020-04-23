class Api::V1::ChatsController < Api::V1::ApiMasterController
before_action :authorize_request
      require 'pubnub'
      require 'json'
      
      def initialize
      end

    #  def send_message_old
    #     @sender = request_user
    #      notification_title = @sender.username + " has sent you a message!"
    #      notification_body = params[:message][0...37]
    #     @recipient = User.find(params[:recipient_id])
    #      message = "This is test message"#params[:message]
    #      #get all devices registered in our db and loop through each of them
    #     n = Rpush::Gcm::Notification.new
    #           # use the pushme_droid app we previously registered in our initializer file to send the notification
    #     n.app = Rpush::Gcm::App.find_by_name("MyGo")
    #     n.registration_ids = [@recipient.device_token]
    #           # parameter for the notification
    #     n.notification = {
    #       body: notification_body,
    #              title: notification_title,
    #              sound: 'default'
    #          }
    #          n.data = { message: message }
    #           #save notification entry in the db
    #     n.save!

    #     if Rpush.push
    #         message = @sender.messages.new(recipient_id: @recipient.id, message: message, created_at: Time.now)
    #         if message.save
    #            chat = Message.get_messages(@sender.id,@recipient.id)
    #            render json: {sent: true, messages: chat }, status: :ok
    #         else
    #            render json: {save: false,message: "couldn't be saved."}
    #         end
    #         render json: true
    #     else
    #         render json: {sent: false,message: "couldn't be sent."}
    #     end 
    # end

    ###### pubnub chat 
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
  publish_key: ENV['PUBLISH_KEY'],
  subscribe_key: ENV['SUBSCRIBE_KEY'],
  uuid: @username
 )
# Only for passing it to JS on client side
#  gon.sub_key = @pubnub_subscribe_key
#  gon.pub_key = @pubnub_publish_key
#  gon.channel = @channel
#  gon.uuid = @username
end

def send_message

  if !params[:recipient_id].blank?
  @pubnub = Pubnub.new(
    publish_key: ENV['PUBLISH_KEY'],
    subscribe_key: ENV['SUBSCRIBE_KEY'],
    uuid: @username
    )
  @sender  = request_user
  @recipient = User.find(params[:recipient_id])
  @username = @sender.first_name + " " + @sender.last_name
  @has_mutual_channel = ChatChannel.check_for_mutual_channel(@sender,@recipient)
  if !@has_mutual_channel.blank?
    @chat_channel = @has_mutual_channel.first
    @remove_current_push_token = @pubnub.remove_channels_from_push(
      remove: @chat_channel.name,
      push_token: @chat_channel.push_token,
      type: 'gcm'
      ).value
    @chat_channel.push_token = @recipient.device_token
    @chat_channel.save
    @channel = @has_mutual_channel.first.name
  else
  @chat_channel = @sender.chat_channels.new(name: @sender.device_token, recipient_id: @recipient.id,push_token: @recipient.device_token)
  @chat_channel.save
  @channel = @chat_channel.name
  end
  
 @message = @sender.messages.new(recipient_id: @recipient.id, message: params[:message], from: User.get_full_name(@sender), user_avatar: @sender.avatar.url)

if @message.save
  
 @recipient_device_token = @recipient.device_token
 @current_push_token = @pubnub.add_channels_to_push(
   push_token: @recipient_device_token,
   type: 'gcm',
   add: @recipient_device_token
   ).value

payload = { 
  "pn_gcm":{
   "notification":{
     "title": @username,
     "body": params[:message]
   },
   data: {
    "id": @message.id,
    "actor_id": request_user.id,
    "actor_image": request_user.avatar.url,
    "notifiable_id": '',
    "notifiable_type": 'chat',
    "action": '',
    "action_type": 'chat',
    "created_at": @message.created_at,
    "body": params[:message]    
   }
  }
 }
 
 @pubnub.publish(
 channel: @recipient_device_token,
 message: payload
 ) do |envelope|
     puts envelope.status
end
   chat = Message.get_messages(@sender.id,@recipient.id)
  
   render json: {
     code: 200,
     success: true,
     message: 'message sent successfully.',
     data: {
       chat: chat
     }
   }

else
  render json: {
    code: 400,
    success: false,
    message: 'Message was not sent.',
    data: nil
  }
end

else
  render json: {
    status: false,
    message: "Recipient Id is required."
  }
 end
end


def chat_history
    if params[:sender_id].blank?
     render json: {
       success: false,
       message: "Sender Id is required."
     }
    else
   @recipient = request_user
   @sender = User::find(params[:sender_id])
   @chat_history = Message.chat_history(@sender,@recipient)
   render json:{ 
     code: 200,
     success: true,
     message: '',
     data:  {
       chat_history: @chat_history
     }
    }
end
end



# chat history from pub nub
# def chat_history
# channel = params[:channel]
# @pubnub.history[]
#  channel: channel ,
#  count: 20,
#  http_sync: true
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

def chat_people
  @chat_people = []
  @IncomingMessages = Message.where(recipient_id: request_user.id)
  @OutgoingMessages = Message.where(user_id: request_user.id)
  @IncomingMessages.map {|msg|
    @chat_people << {
      :user => msg.user,
      :last_message => Message.where(user_id: msg.user.id).where(recipient_id: request_user.id).or(Message.where(user_id: request_user.id).where(recipient_id: msg.user.id)).order(created_at: 'DESC').first
    }
}
  @OutgoingMessages.map {|msg| 
  @chat_people << {
    :user => msg.recipient,
    :last_message => Message.where(user_id: request_user.id).where(recipient_id: msg.recipient.id).or(Message.where(user_id: msg.recipient.id).where(recipient_id: request_user.id)).order(created_at: 'DESC').first
  } 
}
  render json: {
  code: 200,
  success: true,
  message: '',
  data: {
    chat_people: if @chat_people.size > 1 then @chat_people.uniq! {|e| e[:user] }  else @chat_people end
  }
}
end

def clear_conversation
  if !params[:user_id].blank?
  @conversation = Message.where(user_id: params[:user_id]).where(recipient_id: request_user.id).or(Message.where(user_id: request_user.id).where(recipient_id: params[:user_id]))
  if @conversation.destroy_all
    render json: {
      code: 200,
      success: true,
      message: 'Converstaion cleard successfully.',
      data: nil
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "Converstaion couldn't be cleard.",
      data: nil
    }
  end
else
  render json: {
      code: 400,
      success: false,
      message: "user_id is required.",
      data: nil
    }
end
end

end
