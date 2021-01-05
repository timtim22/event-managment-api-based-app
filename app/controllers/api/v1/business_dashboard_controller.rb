class Api::V1::BusinessDashboardController < Api::V1::ApiMasterController
  before_action :authorize_request, except: ['create']
  before_action :checkout_logout, except: :create
  before_action :business

  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def home
    profile = {
      "id" => business.id,
      "profile_name" => business.business_profile.profile_name,
      "avatar" => business.avatar,
      "about" => business.business_profile.about,
      "unread_messages_count" => business.incoming_messages.unread.size,
      "address" => business.business_profile.address,
      # # "location" => {
      # #   "name" => business.business_profile.location,
      # #   "geometry" => {
      # #     "lat" => business.business_profile.lat,
      # #     "lng" => business.business_profile.lng
      # #   }
      # },
      "social" => {
        "youtube" => business.business_profile.youtube,
        "instagram" => business.business_profile.instagram,
        "facebook" => business.business_profile.facebook,
        "linkedin" => business.business_profile.linkedin,
        "twitter" => business.business_profile.twitter,
        "website" => business.business_profile.website
      },
      
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


  def events
    @events = []
    business.child_events.page(params[:page]).per(30).each do |e|
      @events << {
        'id' => e.id,
        'name' => e.name,
        'start_date' => e.start_date,
        'end_date' => e.end_date,
        'start_time' => e.start_time,
        'end_time' => e.end_time,
        'image' => e.image,
        'location' => e.location,
        'price' => get_price(e.event),
        'price_type' => get_price_type(e.event)
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

  end


  def special_offers
    @special_offers = business.special_offers.page(params[:page]).per(20).order(id: 'DESC')
    @offers = []
    @special_offers.each do |offer|
      location = {
        name: offer.location,
        geometry: {
          lat: offer.lat,
          lng: offer.lng
        }
      }
      @offers << {
        id: offer.id,
        title: offer.title,
        image: offer.image,
        location: location,
        validity: offer.validity.strftime(get_time_format),
        description: offer.description,
        ambassador_rate: offer.ambassador_rate,
        terms_conditions: offer.terms_conditions, 
        creator_name: get_full_name(offer.user), 
        creator_image: offer.user.avatar, 
        start_time: offer.time, 
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
  end


  def competitions
    @competitions = []
    business.competitions.page(params[:page]).per(30).each do |competition|
      location = {
        name: competition.location,
        geometry: {
          lat: competition.lat,
          lng: competition.lng
        }
      }
      @competitions <<  {
        id: competition.id,
        title: competition.title,
        description: competition.description,
        location: location,
        image: competition.image.url,
        start_date: competition.start_date,
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
  end



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



  private

   def business
   business = request_user
   end


end
