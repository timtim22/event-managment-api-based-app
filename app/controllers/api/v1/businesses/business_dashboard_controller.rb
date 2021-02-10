class Api::V1::Business::BusinessDashboard < Api::V1::ApiMasterController
  before_action :authorize_request
  before_action :business

  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper



  def home
    profile = {
      "id" => business.id,
      "profile_name" => business.business_profile.profile_name,
      "avatar" => business.avatar,
      "about" => business.business_about,
      "unread_messages_count" => business.incoming_messages.unread.size,
      "address" => eval(business.business_profile.address),
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


  def events
    @events = []
    business.child_events.page(params[:page]).per(30).each do |e|
      @events << {
        'id' => e.id,
        'name' => e.title,
        'start_date' => e.start_date,
        'end_date' => e.end_date,
        'image' => e.event.image,
        'location' => eval(e.location),
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

  end

  def special_offers
    @special_offers = business.special_offers.page(params[:page]).per(20).order(id: 'DESC')
    @offers = []
    @special_offers.each do |offer|
      @offers << {
        id: offer.id,
        title: offer.title,
        image: offer.image,
        location: eval(offer.location),
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
  end


  def competitions
    @competitions = []
    business.competitions.page(params[:page]).per(30).each do |competition|
      @competitions <<  {
        id: competition.id,
        title: competition.title,
        description: competition.description,
        location: eval(competition.location),
        image: competition.image,
        start_date: competition.start_date,
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
            event_name: e.title,
            event_image: e.image,
            event_location: eval(e.location),
            event_date: e.start_date,
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
          event_name: e.title,
          event_image: e.image,
          event_location: eval(e.location),
          event_date: e.start_date,
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
            'name' => e.title,
            'description' => e.description,
            'start_date' => e.start_date,
            'creation_date' => e.created_at,
            'end_date' => e.end_date,
            'price' => get_price(e.event), # check for price if it is zero
            'price_type' => e.event.price_type,
            'event_type' => e.event_type,
            'additional_media' => e.event.event_attachments,
            'location' => eval(e.location),
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
            "terms_and_conditions" => e.terms_conditions,
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

  private


end
