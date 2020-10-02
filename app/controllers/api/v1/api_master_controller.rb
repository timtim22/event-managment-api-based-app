
class Api::V1::ApiMasterController < ApplicationController
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
    protect_from_forgery with: :null_session

 
     
      def not_found
        render json: { error: 'not_found' }
      end

      def authorize_request
        header = request.headers['Authorization']
        token = header.split(' ').last if header
        begin
          @decoded = decode(token)
          @current_user = User.find(@decoded[:user_id])
          rescue ActiveRecord::RecordNotFound => e
          render json: { errors: e.message }, status: :unauthorized
         rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
      end

      def checkout_logout
         header = request.headers['Authorization']
         token = header.split(' ').last if header
         if session[:logout] == token
          render json: {
            "code": 400,
            "success": false,
            "message": "You need to login first",
            "data": nil
          }.to_json
        end
      end

      def encode(payload, exp = 24.years.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY)
      end
    
      def decode(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]
        HashWithIndifferentAccess.new decoded
      end
      
      #API based user
      def request_user
        header = request.headers['Authorization']
        token = header.split(' ').last if header
        if token
         @decoded = decode(token)
         @current_user = User.find(@decoded[:user_id])
        end
      end

      def get_user_from_token(token)
        @decoded = decode(token)
        @current_user = User.find(@decoded[:user_id])
      end
    

      #Applicable to invite frineds only
      def auto_friendship(inviter, invitee)
            friend_request = FriendRequest.new(user_id: inviter.id, friend_id: invitee.id, status: 'accepted')
            if friend_request.save
              friend_request_again = FriendRequest.new(user_id: invitee.id, friend_id: inviter.id, status: 'accepted')
              friend_request_again.save
            end
      end

    
      def get_demographics(event)
        males = []
        females = []
        gays = []
        demographics = {}
        total_count = event.interest_levels.size
        event.interest_levels.each do |level| 
         case level.user.profile.gender
           when 'male'
             males.push(level.user)
           when 'female'
             females.push(level.user)
           when 'gay'
             gays.push(level.user)
           else
              'No users'
            end
         end #each
         
          demographics['males_percentage'] = if males.size > 0 then males.uniq.size.to_f / total_count.to_f * 100.0 else 0 end
    
          demographics['females_percentage'] = if females.size > 0 then females.uniq.size.to_f / total_count.to_f * 100.0  else 0 end
    
          demographics['gays_percentage'] = if gays.size > 0 then gays.uniq.size.to_f / total_count.to_f * 100.0  else 0 end
    
          demographics
     end

    

   
  
     def is_my_friend?(user)
      request_user.friends.include?  user
     end
  
     def is_my_following?(user)
      if request_user
       request_user.followings.include? user
      else
        false
      end
      end

     def is_expired?(offer)
      if offer.validity > DateTime.now
        false
      else
        true
      end
    end

    def getInterestedUsers(event)
      @interested_followers = []
      @interested_others = []
      event.interested_users.uniq.each do |user|
     if request_user
      if request_user.friends.include? user
         @interested_followers.push(get_user_object(user)) 
      else
         if not_me?(user)
          @interested_others.push(get_user_object(user))
         end
      end
    end
    end #each
    @interested_users = {
      "interested_friends" => @interested_followers,
      "interested_others" => @interested_others
    }
    @interested_users
   
    end
  
   #chat specific



   def get_price(event)
    price = ''
   if !event.tickets.blank?
       event.tickets.each do |ticket|
         if ticket.ticket_type == "buy" && event.tickets.size > 1
            prices = []
            prices.push(ticket.price)
            start_price = prices.min
            end_price = prices.max
            price = start_price.to_s + '-' +  end_price.to_s
         elsif ticket.ticket_type == "free"
            price = ticket.price
         elsif ticket.ticket_type == "pay_at_door"
            price = ticket.start_price.to_s + '-' + ticket.end_price.to_s
         else
            price = ticket.price
         end
       end# each
   end# not empty
   price
 end





 





  def get_price_type(event)
    price_type = ''
    if !event.tickets.blank?
      price_type = event.tickets.first.ticket_type
    else
      price_type = 'no_admission_resources'
    end
     price_type
  end

  def has_passes?(event)
    !event.passes.blank?
  end
   
end

