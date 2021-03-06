class Api::V1::Events::EventsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['events_list_by_date','index','show_event','get_map_events']



  api :POST, '/api/v1/events/show', 'To view a specific event'
  param :event_id, :number, :desc => "Event ID", :required => true


  def show_event
    if !params[:event_id].blank?
        child_event = ChildEvent.find(params[:event_id])
        e = child_event
          @passes = []
          @ticket = []
          all_pass_added = false
          if request_user
            all_pass_added = has_passes?(e.event) && all_passes_added_to_wallet?(request_user, e.event.passes)
          e.event.passes.upcoming.map { |pass|
          if !is_removed_pass?(request_user, pass)
            @passes << {
            id: pass.id,
            title: pass.title,
            host_image: e.user.avatar,
            event_title: e.title,
            event_image: e.image,
            event_location: e.location,
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
        e.event.passes.upcoming.map { |pass|
          @passes << {
          id: pass.id,
          title: pass.title,
          host_image: e.user.avatar,
          event_title: e.title,
          event_image: e.image,
          event_location: e.location,
          event_date: e.start_time,
          event_location: e.location,
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
            'start_date' => e.event.start_time,
            'end_date' => e.event.end_time,
            'start_time' => e.event.start_time,
            'end_time' => e.event.end_time,
            'price' => get_price(e.event), # check for price if it is zero
            'price_type' => e.event.price_type,
            'event_type' => e.event_type,
            'additional_media' => e.event.event_attachments,
            'location' => jsonify_location(e.location),
            'image' => e.event.image,
            'venue' => e.event.venue,
            'is_interested' => is_interested?(e),
            'is_going' => is_attending?(e),
            'is_followed' => is_followed(e.user),
            'interest_count' => e.interested_interest_levels.size,
            'going_count' => e.going_interest_levels.size,
            'demographics' => get_demographics(e),
            'going_users' => e.going_users,
            "interested_users" => getInterestedUsers(e),
            'creator_name' => get_full_name(e.user),
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
            "all_passes_added_to_wallet" => all_pass_added,
            "parent_event_id" => e.event.id
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

  api :post, '/api/v1/events/get-list', 'Get events by list'

  def index
    cats_id = []
    if !params[:price].blank?
        case
        when params[:price].to_i == 0
          operator = "="
        when params[:price].to_i == 60
          operator = "<"
        when params[:price].to_i > 60
          operator = ">"
        when params[:price].to_i < 60
          operator = "<"
        else
          "do nothing"
        end
      end
      if !params[:categories].blank?

        cats_ids = params[:categories].split(",").map {|s| s.to_i }
      end

      if !params[:location].blank?

        location = trim_space(params[:location])
      else
        location = nil
      end

      #all events 1
      @events = ChildEvent.active.upcoming.active

      #location based events 2
      @events = ChildEvent.active.active.ransack(location_name_cont: location).result(distinct: true) if !params[:location].blank?
     
      # price based events 3
       @events =  ChildEvent.active.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(ChildEvent.active.where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(ChildEvent.active.where("price < ?", 1).where("end_price #{operator} ?", params[:price]))) if !params[:price].blank?

       #categories 3
       @events = ChildEvent.active.where(first_cat_id: cats_ids) if !params[:categories].blank?

       #has passes  4
       @events = ChildEvent.active.where(pass: 'true') if !params[:pass].blank?

       #location && price 5
       @events = ChildEvent.active.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(ChildEvent.active.where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(ChildEvent.active.where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_name_cont: location).result(distinct: true)  if !params[:location].blank? && !params[:price].blank?

       # locatiion && categories 6
        @events = ChildEvent.active.where(first_cat_id: cats_ids).ransack(location_name_cont: location).result(distinct: true) if !params[:location].blank? && !params[:categories].blank?

        #location && pass 7
        @events = ChildEvent.active.where(pass: 'true').ransack(location_name_cont: location).result(distinct: true) if !params[:location].blank? && !params[:pass].blank?

         #price && categories 8
         @events = ChildEvent.active.where(first_cat_id: cats_ids).where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(ChildEvent.active.where(first_cat_id: cats_ids).where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(ChildEvent.active.where(first_cat_id: cats_ids).where("price < ?", 1).where("end_price #{operator} ?", params[:price]))) if !params[:categories].blank? && !params[:price].blank?

         #price && pass 9
         @events = ChildEvent.active.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).where(pass: 'true').or(ChildEvent.active.where(pass: "true").where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(ChildEvent.active.where(pass: "true").where("price < ?", 1).where("end_price #{operator} ?", params[:price]))) if !params[:price].blank? && !params[:pass].blank?

          #categories && pass 10
          @events = ChildEvent.active.where(pass: 'true').where(first_cat_id: cats_ids) if !params[:categories].blank? && !params[:pass].blank?

           #location ,categories, price 11
           @events = ChildEvent.active.where(first_cat_id: cats_ids).where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(ChildEvent.active.where(first_cat_id: cats_ids).where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(ChildEvent.active.where(first_cat_id: cats_ids).where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_name_cont: location).result(distinct: true) if !params[:location].blank? && !params[:categories].blank? && !params[:price].blank?

            #location ,pass, price 12
            @events = ChildEvent.active.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).where(pass: 'true').or(ChildEvent.active.where(pass: "true").where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(ChildEvent.active.where(pass: "true").where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_name_cont: location).result(distinct: true) if !params[:price].blank? && !params[:pass].blank? && !params[:location].blank?

            #location ,pass, categories 13
            @events = ChildEvent.active.where(pass: 'true').where(first_cat_id: cats_ids).ransack(location_name_cont: location).result(distinct: true) if !params[:categories].blank? && !params[:pass].blank? && !params[:categories].blank?

            #location ,pass, categories, price 14
            @events = ChildEvent.active.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).where(pass: 'true').where(first_cat_id: cats_ids).or(ChildEvent.active.where(pass: "true").where(first_cat_id: cats_ids).where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(ChildEvent.active.where(pass: "true").where(first_cat_id: cats_ids).where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_name_cont: location).result(distinct: true) if !params[:price].blank? && !params[:pass].blank? && !params[:location].blank? && !params[:categories].blank?

            @response = @events.upcoming.sort_by_date.page(params[:page]).per(75).map {|event| get_simple_child_event_object(event) }
            render json: {
              code: 200,
              size: @response.size,
              operator: operator,
              cats_ids: cats_ids,
              success: true,
              data:  {
                events: @response
              }
            }
      end #func


 #  api :POST, '/api/v1/events-by-date', 'Get events by date'
 #  param :date, String, :desc => "Date", :required => true

	# def events_list_by_date
	# 	@events = Event.events_by_date(params[:date])
	# 	render json: @events
	# end

  api :POST, '/api/v1/events/report-event', 'To repot an event'
  param :event_id, String, :desc => "Event ID", :required => true
  param :reason, String, :desc => "Reason for reporting an event", :required => true


  def report_event
   if !params[:event_id].blank? && !params[:reason].blank?
    if request_user.reported_events.create!(event_id: params[:event_id], reason: params[:reason])
    render json: {
      code: 200,
      success: true,
      message: 'Event successfully reported.',
      data: nil
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "Event couldn't be reported."
    }
  end
   else
    render json: {
      code: 400,
      success: false,
      message: 'event_id and reason are required fields.',
      data: nil
    }
   end

  end

  api :POST, '/api/v1/events/create-impression', 'To create impression'
  param :event_id, :number, :desc => "Event ID", :required => true

  def create_impression
    if !params[:event_id].blank?
      event = ChildEvent.find(params[:event_id])
    if view = event.views.create!(user_id: request_user.id, business_id: event.user.id)
      render json: {
        code: 200,
        success: true,
        message: "Event view successfully created.",
        data: nil
      }
      else
        render json: {
        code: 400,
        success: false,
        message: event.errors.full_messages,
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: "event_id is requried field.",
        data: nil
      }
    end
  end

 

  def get_map_events
    if !params[:date].blank?
      date = Date.parse(params[:date])
      @events = ChildEvent.active.where(start_time:  date.midnight..date.end_of_day)
      events  = @events.map {|event| get_map_event_object(event) }
      render json: {
        code: 200,
        success: true,
        message: "",
        data: {
          events: events
        }
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "date is required field.",
        data: nil
      }
  end
  end



private




  def get_map_event_object(event)
      event = {
        "id" => event.id,
        "price_type" => event.event.price_type,
        "max_price" => get_max_price(event.event),
        "has_passes" => has_passes?(event.event),
        "categories" => event.event.categories,
        "location" => jsonify_location(event.location)
      }
  end

     def get_simple_child_event_object(child_event)
        if request_user
          all_pass_added = has_passes?(child_event.event) && all_passes_added_to_wallet?(request_user,child_event.event.passes)
        else
          all_pass_added = false
        end
      e = {
        "id" => child_event.id,
        "venue" => child_event.venue,
        "image" => child_event.event.image,
        "title" => child_event.event.title,
        "description" => child_event.event.description,
        "location" => jsonify_location(child_event.location),
        "start_date" => child_event.start_time,
        "end_date" => child_event.end_time,
        "start_time" => child_event.start_time,
        "end_time" => child_event.end_time,
        "over_18" => child_event.event.over_18,
        "price_type" => child_event.price_type,
        "price" => get_price(child_event.event).to_s,
        "has_passes" => has_passes?(child_event.event),
        "all_passes_added_to_wallet" => all_pass_added,
        "created_at" => child_event.created_at,
        "categories" => child_event.event.categories
      }
     end

  # calculates interest level demographics interested + going

	def event_params
		params.permit(:name,:date, :external_link, :terms_conditions,  :description,:location,:image, :additinal_media, :allow_chat,:event_forwarding,:allow_additional_media,:over_18, :venue)
  end
end
