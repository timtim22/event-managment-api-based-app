
class Api::V1::ApiMasterController < ApplicationController
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
    protect_from_forgery with: :null_session
    #before_action :check_if_app_user?



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

    def is_competition_over?(competition)
       competition.end_date < DateTime.now
    end



    def getInterestedUsers(event)
      @interested_users = []
      @interested_followers_or_friends = []
      @interested_others = []
        @key = "interested_friends"
      if request_user && request_user.app_user == true
        @key = "interested_friends"
      elsif request_user && request_user.web_user == true
        @key = "interested_followers"
      end
      event.interested_users.uniq.each do |user|
          if request_user && request_user.app_user == true
            if request_user.friends.include? user
              @interested_followers_or_friends.push(get_user_object(user))
            else
              if not_me?(user)
                @interested_others.push(get_user_object(user))
              end
          end
          elsif request_user && request_user.web_user == true
            if request_user.followers.include? user
              @interested_followers_or_friends.push(get_user_object(user))
            else
              if not_me?(user)
                @interested_others.push(get_user_object(user))
              end
            end
        end
      end #each

      @interested_users = {
           @key => @interested_followers_or_friends,
          "interested_others" => @interested_others
        }
      @interested_users
  end




     def get_simple_event_object(event)
        if request_user
          all_pass_added = has_passes?(event.event) && all_passes_added_to_wallet?(request_user,event.event.passes)
        else
          all_pass_added = false
        end
      e = {
        "id" => event.id,
        "image" => event.event.image,
        "title" => event.title,
        "description" => event.description,
        'location' => jsonify_location(event.location),
        "start_date" => event.end_date,
        "end_date" => event.end_date,
        "over_18" => event.event.over_18,
        "price_type" => event.price_type,
        "price" => get_price(event.event).to_s,
        "has_passes" => has_passes?(event.event),
        "all_passes_added_to_wallet" => all_pass_added,
        "created_at" => event.created_at,
        "categories" => event.event.categories
      }
     end


    def get_per_page
      per_page = 30
    end


    def event_expired?(event)
      event.end_date < DateTime.now
    end



    def get_offer_demographics(offer)
        males = []
        females = []
        gays = []
        demographics = {}
        total_count = offer.wallets.size
        offer.wallets.each do |wallet|
         case wallet.user.profile.gender
           when 'male'
             males.push(wallet.user)
           when 'female'
             females.push(wallet.user)
           when 'other'
             gays.push(wallet.user)
           else
              'No users'
            end
         end #each

         if males.size > 0 
          percentage = males.uniq.size.to_f / total_count.to_f * 100.0 
          males_percentage = percentage.round(2)
        else 
          males_percentage = 0 
        end

       if females.size > 0  
          percentage = females.uniq.size.to_f / total_count.to_f * 100.0
          female_percentage = percentage.round(2)  
        else
          female_percentage = 0 
         end

        if gays.size > 0 
           percentage = gays.uniq.size.to_f / total_count.to_f * 100.0  
           gays_percentage = percentage.round(2) 
          else
           gays_percentage = 0 
          end

          
          demographics['males_percentage'] = males_percentage
  
          demographics['females_percentage'] = female_percentage
  
          demographics['gays_percentage'] = gays_percentage
  
          demographics

    end


    def get_competition_demographics(competition)
      males = []
      females = []
      gays = []
      demographics = {}
      total_count = competition.registrations.size
      competition.registrations.each do |reg|
       case reg.user.profile.gender
         when 'male'
           males.push(reg.user)
         when 'female'
           females.push(reg.user)
         when 'other'
           gays.push(reg.user)
         else
            'No users'
          end
       end #each

       if males.size > 0 
        percentage = males.uniq.size.to_f / total_count.to_f * 100.0 
        males_percentage = percentage.round(2)
      else 
        males_percentage = 0 
      end

     if females.size > 0  
        percentage = females.uniq.size.to_f / total_count.to_f * 100.0
        female_percentage = percentage.round(2)  
      else
        female_percentage = 0 
       end

      if gays.size > 0 
         percentage = gays.uniq.size.to_f / total_count.to_f * 100.0  
         gays_percentage = percentage.round(2) 
        else
         gays_percentage = 0 
        end

        demographics['males_percentage'] = males_percentage
  
        demographics['females_percentage'] = female_percentage

        demographics['gays_percentage'] = gays_percentage

        demographics

  end
  
   def added_to_wallet?(user, resource)
     w = resource.wallets.where(user: user)
     !w.blank?
   end



   def create_impression
    
    if params[:resource_id].present? && params[:resource_type].present?
       resource = params[:resource_type].constantize
       resource_obj = resource.find(params[:resource_id])
       business = resource_obj.user
       view = request_user.views.create!(resource: resource_obj, business: business)

      
       if view
        render json: {
          code: 200,
          success: true,
          message: "View successfully created.",
          data: nil
        }
    else
      render json: {
        code: 400,
        success: false,
        message: "View creation failed.",
        data: @resource
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: "resource_id and resource_type are requried field."
      }
    end
   end


    private
    def check_if_app_user?
      if request_user && request_user.app_user != true && params["controller"] != "api/v1/analytics" && params["controller"] != "api/v1/business_dashboard"
         render json: {
           code: 400,
           success: false,
           message: 'Being a business user you can not perform any app operation here.',
           data: nil
         }
         return
      end
    end

end

