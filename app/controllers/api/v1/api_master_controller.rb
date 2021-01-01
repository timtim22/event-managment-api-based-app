
class Api::V1::ApiMasterController < ApplicationController
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
    protect_from_forgery with: :null_session
    before_action :check_if_app_user?



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

    def is_competition_over?(competition)
      if competition.end_date > DateTime.now
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

     def get_simple_event_object(event)
        if request_user
          all_pass_added = has_passes?(event) && all_passes_added_to_wallet?(request_user,event.passes)
        else
          all_pass_added = false
        end
      e = {
        "id" => event.id,
        "image" => event.image,
        "name" => event.name,
        "description" => event.description,
        "location" => insert_space_after_comma(event.location),
        "start_date" => event.end_date,
        "end_date" => event.end_date,
        "start_time" => event.start_time,
        "end_time" => event.end_time,
        "over_18" => event.over_18,
        "price_type" => get_price_type(event.event),
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
        total_count = offer.redemptions.size
        offer.redemptions.each do |redeem|
         case redeem.user.profile.gender
           when 'male'
             males.push(redeem.user)
           when 'female'
             females.push(redeem.user)
           when 'gay'
             gays.push(redeem.user)
           else
              'No users'
            end
         end #each

          demographics['males_percentage'] = if males.size > 0 then males.uniq.size.to_f / total_count.to_f * 100.0 else 0 end

          demographics['females_percentage'] = if females.size > 0 then females.uniq.size.to_f / total_count.to_f * 100.0  else 0 end

          demographics['gays_percentage'] = if gays.size > 0 then gays.uniq.size.to_f / total_count.to_f * 100.0  else 0 end

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
         when 'gay'
           gays.push(reg.user)
         else
            'No users'
          end
       end #each

        demographics['males_percentage'] = if males.size > 0 then males.uniq.size.to_f / total_count.to_f * 100.0 else 0 end

        demographics['females_percentage'] = if females.size > 0 then females.uniq.size.to_f / total_count.to_f * 100.0  else 0 end

        demographics['gays_percentage'] = if gays.size > 0 then gays.uniq.size.to_f / total_count.to_f * 100.0  else 0 end

        demographics
   
  end



  def get_total_event_earning(event)
    @total_amount = 0.0
    event.tickets.map {|ticket| ticket.ticket_purchases.map {|p| total_amount += p.price } }
    @total_amount
  end

 def get_total_event_checked_in(event)
   total_checked_in = 0
   event.passes.map {|pass| total_checked_in += pass.redemptions.size }
   event.tickets.map {|ticket| total_checked_in += ticket.redemptiions.size }
   total_checked_in
 end


 def get_event_pass_checked_in(event)
  pass_checked_in = 0
  event.passes.map {|pass| pass_checked_in += pass.redemptions.size }
  pass_checked_in
 end


 def get_event_paid_checked_in(event)
   paid_checked_in = 0
   event.tickets.map {|ticket| paid_checked_in += ticket.redemptiions.size }
   paid_checked_in
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

