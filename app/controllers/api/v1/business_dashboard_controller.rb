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
      # sponsors = []
      # additional_media = []
      # location = {
      #   "name" => e.location,
      #   "geometry" => {
      #     "lat" => e.lat,
      #     'lng' => e.lng
      #   }
      # }

      # admission_resources = {
      #   "ticketes" => e.tickets,
      #   "passes" => e.passes
      # }

      # if !e.sponsors.blank?
      #   e.sponsors.each do |sponsor|
      #   sponsors << {
      #     "sponsor_image" => sponsor.sponsor_image.url,
      #     "external_url" => sponsor.external_url
      #   }
      #  end #each
      # end

      # if !e.event_attachments.blank?
      #   e.event_attachments.each do |attachment|
      #   additional_media << {
      #     "media_type" => attachment.media_type,
      #     "media" => attachment.media.url 
      #   }
      #  end#each 
      # end

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
        validity: offer.validity,
        description: offer.description,
        ambassador_rate: offer.ambassador_rate,
        terms_conditions: offer.terms_conditions 
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
    competitions = []
    business.competitions.page(params[:page]).per(20).each do |competition|
      competitions <<  get_competition_object(competition)
    end #each

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        competitions: competitions
      }
    }
  end



  private

   def business
   business = request_user
   end


end
