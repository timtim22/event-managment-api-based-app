class Api::V1::Businesses::BusinessDashboardController < Api::V1::ApiMasterController
  before_action :authorize_request
  before_action :business

  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper


 api :get, '/api/v1/businesses/get-dashboard', 'To get a business events'

  def home
    profile = {
      "id" => business.id,
      "profile_name" => business.business_profile.profile_name,
      "avatar" => business.avatar,
      "about" => business.about,
      "unread_messages_count" => business.incoming_messages.unread.size,
      "address" => jsonify_location(business.location),
      "social" => business.social_media,
      "news_feeds" => business.news_feeds,
      "followers_count" =>  business.followers.size
    }

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        dashboard: profile
      }
    }

  end


  def_param_group :get_events do
    property :id, String, desc: 'Primary key'
    property :title, String, desc: 'Event title'
    property :start_date, String, desc: 'Event start date'
    property :end_date, String, desc: 'Event end date'
    property :start_time, String, desc: 'Event start time'
    property :end_time, String, desc: 'Event end time'
    property :image, String, desc: 'Event image'
    property :location, String, desc: 'Event location'
    property :price, String, desc: 'Event ticket price'
    property :price_type, String, desc: 'Event ticket price type'
    property :has_passes, [true, false], desc: 'True if an event has passes'
  end


  api :POST, '/api/v1/businesses/get-events', 'To get a business events'
  param :business_id, String, :desc => "User ID", :required => true
  returns array_of: :get_events, code: 200, desc: 'This api will return the following response.' 

  def get_events
   if !params[:business_id].blank?
    business = User.find(params[:business_id])
    @events = []
    business.child_events.page(params[:page]).per(30).each do |e|
      @events << {
        'id' => e.id,
        'title' => e.title,
        'start_date' => get_date_time_mobile(e.start_time),
        'end_date' => get_date_time_mobile(e.end_time),
        'start_time' => get_date_time_mobile(e.start_time),
        'end_time' => get_date_time_mobile(e.end_time),
        'image' => e.event.image,
        'location' => jsonify_location(e.location),
        'price' => get_price(e.event),
        'price_type' => e.event.price_type,
        'has_passes' => has_passes?(e.event)
     }
     
    end #each
    render json: {
      code: 200,
      success: true,
      message: '',
      data: { 
       "events" =>  @events
     }
  }
    else
      render json: {
      code: 400,
      success: false,
      message: "business_id is required field.",
      data: nil
    }
  end
 end



 def_param_group :get_special_offers do
  property :id, String, desc: 'Primary key'
  property :title, String, desc: 'Offer title'
  property :validity, String, desc: 'Offer validity'
  property :description, String, desc: 'Offer description'
  property :ambassador_rate, String, desc: 'Offer ambassador rate per share'
  property :location, String, desc: 'Offer location'
  property :terms_conditions, String, desc: 'Offer terms and conditions'
  property :creator_name, String, desc: 'Offer business name'
  property :start_time, String, desc: 'The time at which the Offer starts'
  property :creation_date, String, desc: 'Offer created at date'
  property :end_date, String, desc: 'Offer end date'
  property :end_time, String, desc: 'Offer end time'
  property :quantity, String, desc: 'Offer total quantity'
  property :redeem_count, String, desc: 'Total number of people who redeemed the offer'
end  


api :POST, '/api/v1/businesses/get-special-offers', 'To get a business special offers'
param :business_id, String, :desc => "User ID", :required => true
returns array_of: :get_special_offers, code: 200, desc: 'This api will return the following response.' 


  def get_special_offers
    if !params[:business_id].blank?
      business = User.find(params[:business_id])
    @special_offers = business.special_offers.page(params[:page]).per(20).order(id: 'DESC')
    @offers = []
    @special_offers.each do |offer|
      @offers << {
        id: offer.id,
        title: offer.title,
        image: offer.image,
        location: jsonify_location(offer.location),
        validity: offer.validity.strftime(get_time_format),
        description: offer.description,
        ambassador_rate: offer.ambassador_rate,
        terms_conditions: offer.terms_conditions, 
        creator_name: get_full_name(offer.user), 
        creator_image: offer.user.avatar, 
        start_time: offer.time,
        creation_date: offer.created_at,
        end_date: offer.validity, 
        end_time: offer.end_time,
        quantity: offer.quantity,
        redeem_count: get_redeem_count(offer)
      }
    end
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        special_offers: @offers
      }
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "business_id is required field.",
      data: nil
    }
  end
  end





 def_param_group :get_competitions do
  property :id, String, desc: 'Primary key'
  property :title, String, desc: 'Competition title'
  property :validity, String, desc: 'Competition validity'
  property :description, String, desc: 'Competition description'
  property :start_date, String, desc: 'Competition start date'
  property :creation_date, String, desc: 'Competition created at'
  property :image, String, desc: 'Competition image'
  property :creator_name, String, desc: 'Competition business name'
  property :creator_image, String, desc: 'Competition business avatar'
  property :end_date, String, desc: 'Competition end date'
  property :terms_conditions, String, desc: 'Competition terms and conditions'
end  


api :POST, '/api/v1/businesses/get-competitions', 'To get a business competitions list'
param :business_id, String, :desc => "User ID", :required => true
returns array_of: :get_competitions, code: 200, desc: 'This api will return the following response.' 


  def get_competitions
    if !params[:business_id].blank?
      business = User.find(params[:business_id])
    @competitions = []
    business.competitions.page(params[:page]).per(30).each do |competition|
      @competitions <<  {
        id: competition.id,
        title: competition.title,
        description: competition.description,
        location: jsonify_location(competition.location),
        image: competition.image,
        start_date: get_date_time_mobile(competition.start_date),
        creation_date: competition.created_at, 
        end_date: competition.end_date,
        creator_name: get_full_name(competition.user),
        creator_image: competition.user.avatar,
        terms_conditions: competition.terms_conditions,
        validity: competition.validity.strftime(get_time_format)
      }
    end #each

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        competitions: @competitions
      }
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "business_id is required field.",
      data: nil
    }
  end
  end




    
  def_param_group :get_business_news_feeds do  
    property :title, String, desc: 'News feed title'
    property :image, String, desc: 'News feed image'
    property :description, String, desc: 'News feed description'
    property :created_at, String, desc: 'News feed date created at'
  end



  api :POST, '/api/v1/businesses/get-news-feeds', 'To get a business news feeds list'
  param :business_id, String, :desc => "User ID", :required => true
  returns array_of: :get_business_news_feeds, code: 200, desc: 'This api will return the following response.'



  def get_business_news_feeds
    if !params[:business_id].blank?
       business_id = params[:business_id]
       @news_feeds = User.find(business_id).news_feeds.page(params[:page]).per(10) 
       render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          news_feeds: @news_feeds
        }
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'business_id is required field.',
        data: nil
      }
    end
  end

 def_param_group :show_event do
  property :id, String, desc: 'Primary key'
  property :title, String, desc: 'event title'
  property :description, String, desc: 'event description'
  property :start_date, String, desc: 'event start date'
  property :end_date, String, desc: 'event end date'
  property :start_time, String, desc: 'event start time'
  property :end_time, String, desc: 'event end time'
  property :creation_date, String, desc: 'Competition created at'
  property :price, String, desc: 'event price'
  property :price_type, String, desc: 'event price type'
  property :event_type, String, desc: 'event event type'
  property :additional_media, String, desc: 'event additional_media'
  property :location, String, desc: 'event location'
  property :image, String, desc: 'event image'
  property :is_interested, String, desc: 'event is_interested'
  property :is_going, String, desc: 'event is_going'
  property :is_followed, String, desc: 'event is_followed'
  property :interest_count, String, desc: 'event interest_count'
  property :going_count, String, desc: 'event going_count'
  property :demographics, String, desc: 'event demographics'
  property :going_users, String, desc: 'event going_users'
  property :interested_users, String, desc: 'event interested_users'
  property :creator_name, String, desc: 'event creator name'
  property :creator_id, String, desc: 'event creator id'
  property :creator_image, String, desc: 'event creator image'
  property :categories, String, desc: 'event categories'
  property :sponsors, String, desc: 'event sponsors'
  property :mute_chat, String, desc: 'event mute_chat'
  property :mute_notifications, String, desc: 'event mute_notifications'
  property :forwards_count, String, desc: 'event forwards_count'
  property :comments_count, String, desc: 'event comments_count'
  property :has_passes, String, desc: 'event passes'
  property :all_passes_added_to_wallet, String, desc: 'event passes add to wallet'
end  


  api :POST, '/api/v1/businesses/events/show', 'To view event'
  param :event_id, String, :desc => "Event ID", :required => true
  returns array_of: :show_event, code: 200, desc: 'This api will return the following response.'

  def show_event
    if !params[:event_id].blank?
        child_event = ChildEvent.find(params[:event_id])
        e = child_event
          @passes = []
          @ticket = []
          all_pass_added = false
          if request_user
            all_pass_added = has_passes?(e.event) && all_passes_added_to_wallet?(request_user, e.event.passes)
          e.event.passes.not_expired.map { |pass|
          if !is_removed_pass?(request_user, pass)
            @passes << {
            id: pass.id,
            title: pass.title,
            host_name: get_full_name(e.user),
            host_image: e.user.avatar,
            event_title: e.title,
            event_image: e.image,
            event_location: jsonify_location(e.location),
            event_date: e.start_time,
            is_added_to_wallet: is_added_to_wallet?(pass.id),
            validity: pass.validity.strftime(get_time_format),
            grabbers_count: pass.wallets.size,
            terms_and_conditions: pass.terms_conditions,
            description: pass.description,
            issued_by: get_full_name(pass.user),
            redeem_count: get_redeem_count(pass),
            quantity: pass.quantity
          }
        end# remove if
      } #map
      else
        e.event.passes.not_expired.map { |pass|
          @passes << {
          id: pass.id,
          title: pass.title,
          description: pass.description,
          host_name: get_full_name(e.user),
          host_image: e.user.avatar,
          event_title: e.title,
          event_image: e.image,
          event_location: jsonify_location(e.location),
          event_date: e.start_time,
          is_added_to_wallet: is_added_to_wallet?(pass.id),
          validity: pass.validity.strftime(get_time_format),
          grabbers_count: pass.wallets.size,
          terms_and_conditions: pass.terms_conditions,
          issued_by: get_full_name(pass.user),
          redeem_count: get_redeem_count(pass),
          quantity: pass.quantity
        }
      }# passes map
      end #if request_user

          @event = {
            'id' => e.id,
            'title' => e.title,
            'description' => e.description,
            'start_date' => get_date_time_mobile(e.start_time),
            'end_date' => get_date_time_mobile(e.end_time),
            'start_time' => get_date_time_mobile(e.start_time),
            'end_time' => get_date_time_mobile(e.end_time),
            'creation_date' => e.created_at,
            'price' => get_price(e.event), # check for price if it is zero
            'price_type' => e.event.price_type,
            'event_type' => e.event_type,
            'additional_media' => e.event.event_attachments,
            'location' => jsonify_location(e.location),
            'image' => e.event.image,
            'is_interested' => is_interested?(e),
            'is_going' => is_attending?(e),
            'is_followed' => is_followed(e.user),
            'interest_count' => e.interested_interest_levels.size,
            'going_count' => e.going_interest_levels.size,
            'demographics' => get_demographics(e),
            'going_users' => e.going_users,
            "interested_users" => getInterestedUsers(e),
            'creator_name' => e.user.business_profile.profile_name,
            'creator_id' => e.user.id,
            'creator_image' => e.user.avatar,
            'categories' => !e.event.categories.blank? ? e.event.categories : @empty,
            'sponsors' => e.event.sponsors,
            "mute_chat" => get_mute_chat_status(e),
            "mute_notifications" => get_mute_notifications_status(e),
            "forwards_count" => e.event_forwardings.count,
            "comments_count" => e.comments.size + e.comments.map {|c| c.replies.size }.sum,
            "has_passes" => has_passes?(e.event),
            "all_passes_added_to_wallet" => all_pass_added
         }

         render json: {
           code: 200,
           success: true,
           message: '',
           user: request_user,
           data: {
             event: @event,
             #business_all_events: e.user.events.sort_by_date.page(params[:page]).per(10).map {|e| get_simple_event_object(e) }
           }
         }

      else
        render json: {
          code: 400,
          success: false,
          message: "event_id is required.",
          data: nil
        }
      end
  end


  
  # def_param_group :get_other_business_profile do
  #   property :id, String, desc: 'id'
  #   property :profile_name, String, desc: 'profile_name'
  #   property :first_name, String, desc: 'first_name'
  #   property :last_name, String, desc: 'last_name'
  #   property :avatar, String, desc: 'avatar'
  #   property :location, String, desc: 'location'
  #   property :social, String, desc: 'social links'
  #   property :website, String, desc: 'website'
  #   property :news_feeds, Hash, desc: 'news_feeds'
  #   property :followers_count, Integer, desc: 'followers_count'
  #   property :events_count, String, desc: 'events_count'
  #   property :offers_count, String, desc: 'offers_count'
  #   property :competitions_count, String, desc: 'competitions_count'
  #   property :ambassador_request_status, String, desc: 'ambassador_request_status'
  #   property :is_ambassador, String, desc: 'is_ambassador'
  # end


  
#   api :POST, '/api/v1/business/get-profile', 'To get other business profile'
#   param :user_id, String, :desc => "User ID", :required => true
#   returns array_of: :get_other_business_profile, code: 200, desc: 'This api will return the following response.' 

#  def get_other_business_profile
#   if !params[:user_id].blank?
#   user = User.find(params[:user_id])
#   profile = {}
#   status = get_request_status(user.id)
#   profile['id'] = user.id
#   profile['profile_name'] = user.business_profile.profile_name
#   profile['first_name'] = user.business_profile.profile_name
#   profile['last_name'] = ''
#   profile['avatar'] = user.avatar
#   profile['location'] = jsonify_location(user.location)
#   profile["social"] = user.social_media
#   profile['website'] = user.business_profile.website
#   profile['followers_count'] = user.followers.size
#   profile['events_count'] = user.events.size
#   profile['competitions_count'] = user.competitions.size
#   profile['offers_count'] = user.special_offers.size
#   profile['news_feeds'] = user.news_feeds
#   profile['ambassador_request_status'] = status
#   profile['is_ambassador'] = false
#   render json: {
#     code: 200,
#     success: true,
#     message: '',
#     data: {
#       profile: profile,
#       user: user
#     }
#   }
# else
#   render json: {
#     code: 400,
#     success: false,
#     message: 'user_id is required.',
#     data: nil
#   }
# end
# end



# def_param_group :get_business_profile do
#   property :first_name, String, desc: 'first_name'
#   property :last_name, String, desc: 'last_name'
#   property :avatar, String, desc: 'avatar'
#   property :about, String, desc: 'about'
#   property :location, String, desc: 'location'
#   property :followers_count, String, desc: 'followers_count'
#   property :offers_count, String, desc: 'offers_count'
#   property :competitions, String, desc: 'competitions'
#   property :competitions_count, String, desc: 'competitions_count'
#   property :events, String, desc: 'events'
#   property :offers, String, desc: 'offers'
# end

# api :get, '/api/v1/business/get-profile', 'To get a business profile'
# returns array_of: :get_business_profile, code: 200, desc: 'This api will return the following response.' 

# #own profile
# def get_business_profile
#     user = request_user
#     profile = {}
#     offers = {}
#     offers['special_offers'] = user.special_offers
#     offers['passes'] = user.passes
#     profile['first_name'] = user.business_profile.profile_name
#     profile['last_name'] = ''
#     profile['avatar'] = user.avatar
#     profile['about'] = user.about
#     profile['location'] = jsonify_location(user.location)
#     profile['followers_count'] = user.followers.size
#     profile['events_count'] = user.events.size
#     profile['competitions_count'] = user.competitions.size
#     profile['offers_count'] = user.passes.size + user.special_offers.size
#     profile['competitions'] = user.competitions
#     profile['events'] = user.events
#     profile['offers'] = offers
#     render json: {
#       code: 200,
#       success: true,
#       message: '',
#       data: {
#         profile: profile
#       }
#     }
# end


  private


def get_date_time(date, time)
    d = date.strftime("%Y-%m-%d")
    t = time.strftime("%H:%M:%S")
    datetime = d + "T" + t + ".000Z"
end

def business
 business = request_user
end

end
