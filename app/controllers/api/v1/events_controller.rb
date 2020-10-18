class Api::V1::EventsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['events_list_by_date','index','show_event']



  def show_event
    if !params[:event_id].blank?
      e = Event.find(params[:event_id])
      @passes = []
          @ticket = []
          if request_user
          e.passes.not_expired.map { |pass|
          if !is_removed_pass?(request_user, pass)
            @passes << {
            id: pass.id,
            title: pass.title,
            host_name: e.user.business_profile.profile_name,
            host_image: e.user.avatar,
            event_name: e.name,
            event_image: e.image,
            event_location: e.location,
            event_start_time: e.start_time,
            event_end_time: e.end_time,
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
        e.passes.not_expired.map { |pass|
          @passes << {
          id: pass.id,
          title: pass.title,
          description: pass.description,
          host_name: e.user.business_profile.profile_name,
          host_image: e.user.avatar,
          event_name: e.name,
          event_image: e.image,
          event_location: e.location,
          event_start_time: e.start_time,
          event_end_time: e.end_time,
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
      }# passes map
      end #if request_user

          @event = {
            'id' => e.id,
            'name' => e.name,
            'description' => e.description,
            'start_date' => e.start_date,
            'end_date' => e.end_date,
            'start_time' => e.start_time,
            'end_time' => e.end_time,
            'price' => get_price(e), # check for price if it is zero
            'price_type' => get_price_type(e),
            'event_type' => e.event_type,
            'additional_media' => e.event_attachments,
            'location' => insert_space_after_comma(event.location),
            'lat' => e.lat,
            'lng' => e.lng,
            'image' => e.image,
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
            'categories' => !e.categories.blank? ? e.categories : @empty,
            'sponsors' => e.sponsors,
            "mute_chat" => get_mute_chat_status(e),
            "mute_notifications" => get_mute_notifications_status(e),
            "terms_and_conditions" => e.terms_conditions,
            "forwards_count" => e.event_forwardings.count,
            "comments_count" => e.comments.size,
            "has_passes" => has_passes?(e) 
         }

         render json: {
           code: 200,
           success: true,
           message: '',
           data: {
             event: @event
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
  

  def index
   
    @events = []
    if params[:filter] == 'true'
     
      #case 1
      if !params[:location].blank? && params[:price].blank? && params[:categories].blank? && params[:pass] != 'true'
        
        @events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
      #case 2
      elsif params[:location].blank? && !params[:price].blank? && params[:categories].blank? && params[:pass] != 'true'
        
        @events = filter_events_by_price(params[:price]).map {|event| get_simple_event_object(event)}
      #case 3
      elsif params[:location].blank? && params[:price].blank? && !params[:categories].blank? && params[:pass] != 'true'
        
       events =  filter_events_by_categories(params[:categories])
       if !events.blank?
        @events = events.map {|event| get_simple_event_object(event) }
       else
        @events = []
       end
      
     # case 4
      elsif params[:location].blank? && params[:price].blank? && params[:categories].blank? && params[:pass] == 'true'
         
         @events =  filter_events_by_pass.map {|event| get_simple_event_object(event) }
    
      ##2222222222222222222222222222222222222222222222222
      #case 5
      elsif !params[:location].blank? && !params[:price].blank? && params[:categories].blank? && params[:pass] != 'true'
        
        location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).sort_by_date.page(params[:page]).per(get_per_page)
        location_based_ids = location_based_events.map {|event| event.id }

        price_based_events = filter_events_by_price(params[:price])
        price_based_ids = price_based_events.map {|event| event.id }
        common_ids = location_based_ids & price_based_ids
        if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event)}
         else
          @events = []
         end
        
       #case 6
      elsif !params[:location].blank? && params[:price].blank? && !params[:categories].blank? && params[:pass] != 'true'
        location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).page(params[:page]).per(get_per_page)
        location_based_ids = location_based_events.map {|event| event.id } 
        cats_based_events = filter_events_by_categories(params[:categories])
        cats_based_ids = cats_based_events.map {|event| event.id }
        common_ids = location_based_ids & cats_based_ids
        if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event)}
         else
          @events = []
         end
   
         #case 7
      elsif !params[:location].blank? && params[:price].blank? && params[:categories].blank? && params[:pass] == 'true'
       location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).sort_by_date.page(params[:page]).per(get_per_page)
       location_based_ids = location_based_events.map {|event| event.id } 
       pass_based_events =  filter_events_by_pass
       pass_based_ids = pass_based_events.map {|event| event.id }
        common_ids = pass_based_ids & location_based_ids
        if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event)}
         else
          @events = []
         end

        #case 8
      elsif  params[:location].blank? && !params[:price].blank? && !params[:categories].blank? && params[:pass] != 'true'
       
        events =   filter_events_by_price(params[:price])
        ids = events.map {|event| event.id }
        cat_based_events =   filter_events_by_categories(params[:categories])
        cat_based_ids = cat_based_events.map {|e| e.id }
         common_ids = ids & cat_based_ids
         if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event)}
         else
          @events = []
         end
         #case 9
      elsif  params[:location].blank? && !params[:price].blank? && params[:categories].blank? && params[:pass] == 'true'
        
        pass_based_events =  filter_events_by_pass
        ids = pass_based_events.map {|event| event.id }
        price_based_events =   filter_events_by_price(params[:price])
        price_based_ids = price_based_events.map {|e| e.id }
        common_ids = ids & price_based_ids
        if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
        else
          @events = []
        end

        #10
      elsif  params[:location].blank? && params[:price].blank? && !params[:categories].blank? && params[:pass] == 'true'
        
        pass_based_events =  filter_events_by_pass
        ids = pass_based_events.map {|event| event.id }
        cat_based_events =   filter_events_by_categories(params[:categories])
        cat_based_ids = cat_based_events.map {|e| e.id }
        common_ids = ids & cat_based_ids
        if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
        else
          @events = []
        end
       ## 333333333333333333333333333333333333333333333333333333333333333333333
       #case 11
      elsif  !params[:location].blank? && !params[:price].blank? && params[:categories].blank? && params[:pass] == 'true'
        location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).sort_by_date.page(params[:page]).per(get_per_page)
        location_based_ids = location_based_events.map {|event| event.id }
         price_based_events = filter_events_by_price(params[:price])
         price_based_ids = price_based_events.map {|event| event.id }
         pass_based_events = filter_events_by_pass
         pass_based_ids = pass_based_events.map {|event| event.id }
         common_ids = location_based_ids & price_based_ids & pass_based_ids
         if !common_ids.blank?
          @events = Event.where(id: common_ids).page(params[:page]).sort_by_date.per(get_per_page).map {|event| get_simple_event_object(event) }
         else
      
          @events = []
         end
        #case 11
      elsif !params[:location].blank? && params[:price].blank? && !params[:categories].blank? && params[:pass] == 'true' 
     
        location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).sort_by_date.page(params[:page]).per(get_per_page)
        location_based_ids = location_based_events.map {|event| event.id }
         category_based_events = filter_events_by_categories(params[:categories])
         category_based_ids = category_based_events.map {|event| event.id }
         pass_based_events = filter_events_by_pass
         pass_based_ids = pass_based_events.map {|event| event.id }
         common_ids = location_based_ids & category_based_ids & pass_based_ids
         if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
         else
          @events = []
         end
        # case 12
         #case 11
      elsif params[:location].blank? && !params[:price].blank? && !params[:categories].blank? && params[:pass] == 'true' 
         
       
         price_based_events = filter_events_by_price(params[:price])
         price_based_ids = price_based_events.map {|event| event.id }
         category_based_events = filter_events_by_categories(params[:categories])
         category_based_ids = category_based_events.map {|event| event.id }
         pass_based_events = filter_events_by_pass
         pass_based_ids = pass_based_events.map {|event| event.id }
         common_ids = price_based_ids & category_based_ids & pass_based_ids
         if !common_ids.blank?
          @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
         else
          @events = []
         end

        elsif !params[:location].blank? && params[:price].blank? && !params[:categories].blank? && params[:pass] == 'true' 
         
         
          location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).page(params[:page]).per(get_per_page)
          location_based_ids = location_based_events.map {|event| event.id }
           category_based_events = filter_events_by_categories(params[:categories])
           category_based_ids = category_based_events.map {|event| event.id }
           pass_based_events = filter_events_by_pass
           pass_based_ids = pass_based_events.map {|event| event.id }
           common_ids = location_based_ids & category_based_ids & pass_based_ids
           if !common_ids.blank?
            @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
           else
            @events = []
           end

          elsif !params[:location].blank? && !params[:price].blank? && !params[:categories].blank? && params[:pass] != 'true' 
           
            location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).sort_by_date.page(params[:page]).per(get_per_page)
            location_based_ids = location_based_events.map {|event| event.id }
             price_based_events = filter_events_by_price(params[:price])
             price_based_ids = price_based_events.map {|event| event.id }
             category_based_events = filter_events_by_categories(params[:categories])
             category_based_ids = category_based_events.map {|event| event.id }
            
             common_ids = price_based_ids & category_based_ids  & location_based_ids
             if !common_ids.blank?
              @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
             else
              @events = []
             end

            elsif !params[:location].blank? && !params[:price].blank? && !params[:categories].blank? && params[:pass] == 'true' 
            
              location_based_events = Event.ransack(location_cont: trim_space(params[:location])).result(distinct: true).sort_by_date.page(params[:page]).per(get_per_page)
              location_based_ids = location_based_events.map {|event| event.id }
               price_based_events = filter_events_by_price(params[:price])
               price_based_ids = price_based_events.map {|event| event.id }
               category_based_events = filter_events_by_categories(params[:categories])
               category_based_ids = category_based_events.map {|event| event.id }
               pass_based_events = filter_events_by_pass
               pass_based_ids = pass_based_events.map {|event| event.id }
               common_ids = price_based_ids & category_based_ids & location_based_ids & pass_based_ids
               if !common_ids.blank?
                @events = Event.where(id: common_ids).sort_by_date.page(params[:page]).per(get_per_page).map {|event| get_simple_event_object(event) }
               else
                @events = []
               end
        
      end #innser if end
      ############################# cases end #############################
    else
     
      events = Event.sort_by_date.page(params[:page]).per(get_per_page).eager_load(:passes, :tickets)
      @events = events.map {|event| get_simple_event_object(event) }  
    end
   
    render json:  {
      code: 200,
      success: true,
      message: '',
      size: @events.size,
      params: params,
      data: {
        events: @events 
      }
    }
  end




	def events_list_by_date
		@events = Event.events_by_date(params[:date])
		render json: @events
	end

	def show
		@event = Event.find(params[:event_id])
		render json: {
			status: true,
			event: @event
		}
	end

	def new
		@event = Event.new
	end

  def create
    @event = Event.new(event_params)
    # Notify all mygo user about event creation
    @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
    )
    (User.all - [request_user]).each do |user|
      if @notification = Notification.create(recipient: user, actor: request_user, action: get_full_name(request_user) + " posted a new event.", notifiable: @event, url: '/admin/events', notification_type: 'web')  
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: user.profile.device_token,
          type: 'gcm',
          add: user.profile.device_token
          ).value

        payload = { 
        "pn_gcm":{
          "notification":{
            "title": @notification.action,
          },
          "type": @notification.notifiable_type,
          "event_id": @event.id 
        }
      }

        @pubnub.publish(
         channel: [user.profile.device_token],
         message: payload
          ) do |envelope|
            puts envelope.status
        end
      end ##notification create
    end #each
		if @event.save
			render json: {
				status: true,
				message: "Event successfully created."
			}
			
		else
		    render json: {
		    	status: false,
		    	message: @event.errors.full_messages
		    }
		end
  end
  
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

  def create_view
    if !params[:event_id].blank?
      event = Event.find(params[:event_id])
    if view = event.views.create!(user_id: request_user.id)
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


  private 

  def filter_events_by_price(price)
       @events = []
       threshhold = 60
       price = price.to_i
      if price == 0
        event_ids = Ticket.where(ticket_type: 'free').page(params[:page]).per(get_per_page).map {|t| t.event_id }
        @events = Event.where(id: event_ids).sort_by_date.page(params[:page]).per(get_per_page)
      elsif price == 60 
        @events = Event.where("price != ?", "0.00").where("price < ?", threshhold).or(Event.where("end_price != ?", "0.00").where("end_price < ?", threshhold).or(Event.where("start_price != ? ", "0.00").where("start_price < ?", threshhold))).sort_by_date.page(params[:page]).per(get_per_page)
      elsif price > 60
        @events = Event.where("price != ?", "0.00").where("price > ?", threshhold).or(Event.where("end_price != ?", "0.00").where("end_price > ?", threshhold).or(Event.where("start_price != ? ", "0.00").where("start_price > ?", threshhold))).sort_by_date.page(params[:page]).per(get_per_page)
      else 
       
        @events = Event.where("price != ?", "0.00").where("price < ?", price).or(Event.where("end_price != ?", "0.00").where("end_price < ?", price).or(Event.where("start_price != ? ", "0.00").where("start_price < ?", price))).sort_by_date.page(params[:page]).per(get_per_page)
      
      end 
 
  end

  def filter_events_by_pass
    events_ids = Pass.all.page(params[:page]).per(get_per_page).map {|p| p.event_id }
    @events = Event.where(id: events_ids).sort_by_date.page(params[:page]).per(get_per_page)
  end

  def filter_events_by_categories(categories_names)
    @events = []
    cat_uuids = categories_names.split(',').map {|s| s.gsub(' ','') }
    cats_ids = Category.where(uuid: cat_uuids).map {|cat| cat.id }.uniq
    @events = Event.where(first_cat_id: cats_ids).sort_by_date.page(params[:page]).per(get_per_page)
  end


 

  # calculates interest level demographics interested + going
 
	def event_params
		params.permit(:name,:date,:start_time, :end_time, :external_link, :host, :description,:location,:image, :feature_media_link, :additinal_media, :allow_chat,:invitees,:event_forwarding,:allow_additional_media,:over_18)
  end
end
