
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
        @decoded = decode(token)
        @current_user = User.find(@decoded[:user_id])
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

      def create_activity(action, resource, resource_type, resource_url,resrource_title, method)
        params.permit(:action, :resource,:user_id, :resource_type,:browser, :params, :url, :method, :resource_title, :method)
       if activity = ActivityLog.create!(user: request_user, action: action, resource: resource, resource_type: resource_type, browser: request.env['HTTP_USER_AGENT'], ip_address: request.env['REMOTE_ADDR'], params: params.inspect,url: resource_url, method: method, resource_title: resrource_title)
        true
       else
        activity.errors.full_messages
       end
      end

      def get_demographics(event)
        males = []
        females = []
        gays = []
        demographics = {}
        total_count = event.interest_levels.size
        event.interest_levels.each do |level| 
         case level.user.gender
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
   

      #chat specific
      
end

