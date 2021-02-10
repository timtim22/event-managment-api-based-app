class Api::V1::Chats::ChatsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['chat_people']
  require 'pubnub'
  require 'json'

  api :POST, '/api/v1/chat/send-message', 'To send a message'
  param :recipient_id, :number, :desc => "Recipient ID", :required => true
  param :message, String, :desc => "Message", :required => true

def send_message

 if !params[:recipient_id].blank? && !params[:message].blank?
 @recipient = User.find(params[:recipient_id])
  if !blocked_user?(request_user, @recipient)
 if !params[:recipient_id].blank?
  @pubnub = Pubnub.new(
    publish_key: ENV['PUBLISH_KEY'],
    subscribe_key: ENV['SUBSCRIBE_KEY'],
    )

  @sender  = request_user

  @username = @sender.profile.first_name + " " + @sender.profile.last_name
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

 @message = @sender.messages.new(recipient_id: @recipient.id, message: params[:message], from: get_full_name(@sender), user_avatar: @sender.avatar)

if @message.save

 @current_push_token = @pubnub.add_channels_to_push(
   push_token: @recipient.device_token,
   type: 'gcm',
   add: @recipient.device_token
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
    "actor_image": request_user.avatar,
    "sender_name": get_full_name(request_user),
    "notifiable_id": '',
    "notifiable_type": 'chat',
    "action": '',
    "action_type": 'chat',
    "created_at": @message.created_at,
    "body": params[:message] ,
    "last_message": @message
   }
  }
 }


if @recipient.all_chat_notifications_setting.is_on && !user_chat_muted?(@recipient, request_user)
  @pubnub.publish(
    channel: @recipient.device_token,
    message: payload
    ) do |envelope|
        puts envelope.status
   end #publish
  end #all chat and event chat true


   chat = []
   messages = Message.get_messages(@sender.id,@recipient.id).order(id: 'ASC')
   if !messages.blank?
    messages.each do |msg|
      chat << {
        "id" => msg.id,
        "recipient_id" =>  msg.recipient_id,
        "message" => msg.message,
        "read_at" => msg.read_at,
        "sender_id" => msg.user_id,
        "created_at" => msg.created_at,
        "updated_at" => msg.updated_at,
        "from" => msg.from,
        "user_avatar": msg.user_avatar
      }
    end #each
   end

   render json: {
     code: 200,
     success: true,
     message: 'Message sent successfully.',
     mute_chat: user_chat_muted?(request_user, @recipient),
     current_user: request_user,
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
    message: "recipient_id and message is required."
  }
 end
else
  render json: {
    code: 400,
    success: false,
    message: "The operation has been blocked!",
    data:nil
  }
end

else
  render json: {
    code: 400,
    success: false,
    message: "recipient_id and message are required fields.",
    data: nil
  }
end
end

  api :POST, '/api/v1/chat/chat-history', 'Get chat history for specific user'
  param :sender_id, :number, :desc => "Sender ID", :required => true

def chat_history
    if params[:sender_id].blank?
     render json: {
       success: false,
       message: "Sender Id is required."
     }
    else
   @chat_history = []
   @recipient = request_user
   @sender = User::find(params[:sender_id])
   Message.chat_history(@sender,@recipient).order(id: 'ASC').each do |history|
      @chat_history << {
        "id" => history.id,
        "recipient_id" => history.recipient_id,
        "message" =>  history.message,
        "read_at" => history.read_at,
        "user_id" => history.user_id,
        "created_at" =>  history.created_at,
        "updated_at" => history.updated_at,
        "from" => get_full_name(history.user),
        "user_avatar" => history.user.avatar.url,
        "sender_id" => history.user.id
      }
   end #each
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

  api :GET, '/api/v1/chat/chat-people', 'Get People who chatted'

def chat_people

  @chat_people = []
  @users = []

  request_user.incoming_messages.map {|msg| @users.push(msg.user) }
  request_user.messages.map {|msg| @users.push(msg.recipient) }

 @users.uniq.each do |user|
        @chat_people << {
        :user => get_user_object(user),
        :last_message => Message.last_message(request_user, user),
        :is_mute => user_chat_muted?(request_user, user),
        :is_blocked => blocked_user?(request_user, user),
        :unread_count => get_unread_message_count(user.id)
      }
 end

  render json: {
  code: 200,
  success: true,
  user: request_user,
  message: '',
  data: {
    chat_people: @chat_people
  }
}
end

  api :POST, '/api/v1/chat/clear-conversation', 'Clear conversation with specific user'
  param :user_id, :number, :desc => "The user ID (perons id you want to clear conversation)", :required => true


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
      message: "conversation couldn't be cleard.",
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



def clear_chat #specific chat
  message = Message.find(params[:message_id])
  if message.destroy
    render json: {
      code: 200,
      success: true,
      message: "Message successfully deleted.",
      data: nil
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "Message deletion failed.",
      data: nil
    }
  end
end

  api :POST, '/api/v1/chat/mark-as-read', 'Mark chats as read'
  param :sender_id, :number, :desc => "Sender ID", :required => true

def mark_as_read
  if !params[:sender_id].blank?
     success = false
     incoming_messages = request_user.incoming_messages.where(user_id: params[:sender_id]).unread
     if !incoming_messages.blank?
     incoming_messages.each do |msg|
      if msg.update!(read_at: Time.zone.now)
        success = true
      else
        success = false
      end
     end#each

     if success == true
      render json: {
        code: 200,
        success: true,
        message: "Messages read successfully.",
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "Message read failed.",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "No unread messages.",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "sender_id is required field.",
      data: nil
    }
  end
end


private

def get_unread_message_count(sender_id)
  count = request_user.incoming_messages.unread.where(user_id: sender_id).size
end

end