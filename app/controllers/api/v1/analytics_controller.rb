class Api::V1::AnalyticsController < Api::V1::ApiMasterController
  before_action :authorize_request



  def get_event_stats
    if !params[:event_id].blank?
      event = ChildEvent.find(params[:event_id])       
        #if ticketed event
       # if event.event.price_type == 'buy'
           #Scenario 1 before live 
        
              stats = {
                 "checked_in" => {
                  "total_checked_in" => get_total_event_checked_in(event.event),
                  "time_slot_total_checked_in" => get_time_slot_total_pass_checked_in(params[:time_slot_dates], event.event) + get_time_slot_total_paid_checked_in(params[:time_slot_dates], event.event),
                  "total_pass_checked_in" => get_pass_total_checked_in(event.event),
                  "time_slot_total_pass_checked_in" => get_event_pass_checked_in(params[:time_slot_dates], event.event),
                  "time_slot_pass_checked_in_date_wise" => get_event_pass_checked_in_date_wise(params[:time_slot_dates], event.event),
                  "total_paid_checked_in" => get_total_paid_checked_in(event.event),
                  "time_slot_total_paid_checked_in" => get_event_paid_checked_in(event.event),
                  "time_slot_paid_checked_in_date_wise" => get_event_paid_checked_in_date_wise(params[:time_slot_dates],event.event)
                 },
                "attendees" => {
                  "max_attendees" => event.event.max_attendees,
                  "max_passes" => event.event.passes.size,
                  "total_attendees" => event.going_interest_levels.size,
                  "time_slot_attendees" => get_time_slot_total_attendees(params[:time_slot_dates], event),
                  "time_slot_attendees_date_wise" => get_time_slot_attendees_date_wise(params[:time_slot_dates], event),
                },
                "total_earning" => get_total_event_earning(event.event),
                "demographics" => get_demographics(event),
                 "impressions" => {
                  "time_slot_total_impressions" => get_time_slot_total_views(params[:time_slot_dates], event),
                  "time_slot_impressions_date_wise" => get_time_slot_event_views_date_wise(params[:time_slot_dates],event),
                 },
                 "interested" => {
                   "time_slot_total_interested_people" => get_time_slot_total_interested_people(params[:time_slot_dates], event),
                   "time_slot_interested_people_date_wise" => get_time_slot_interested_people_date_wise(params[:time_slot_dates],event),
                 },
                 "shares" => {
                  "time_slot_total_shared_events" => get_time_slot_total_shared_events(params[:time_slot_dates], event),
                  "time_slot_shares_date_wise" => get_time_slot_shares_date_wise(params[:time_slot_dates],event),
                 },
                 "pass" => {
                  "total_pass_checked_in" => get_pass_total_checked_in(event.event),
                  "time_slot_total_pass_checked_in" => get_event_pass_checked_in(event.event),
                  "time_slot_pass_checked_in_date_wise" => get_event_pass_checked_in_date_wise
                 }
                }
        
              @event_stats = {
                "event_id" => event.id,
                "name" => event.name,
                "start_date" => event.start_date,
                "end_date" => event.end_date,
                "start_time" => event.start_time,
                "end_time" => event.end_time,
                "location" => event.location,
                "lat" => event.lat,
                "lng" => event.lng,
                "event_type" => event.event_type,
                "image" => event.image,
                "price_type" => event.event.price_type,
                "price" => event.event.price,
                "additional_media" => event.event.event_attachments,
                "created_at" => event.created_at,
                "updated_at" => event.updated_at,
                "stats" => stats
                }
          #  else 
     
          #  end
      
      #non ticketed event  
    #   else
    # end
      
     render json: {
       code: 200,
       success: true,
       message: '',
       data: {
         stats: @event_stats
       }
     }
    else
      render json: {
        code: 400,
        success: true,
        message: '',
        data: nil
      }
    end
  end



  def get_offer_stats
    if !params[:special_offer_id].blank? && !params[:time_slot_dates].blank?
    special_offer = SpecialOffer.find(params[:special_offer_id])
      stats = {
        "id" => special_offer.id,
        "total_redemptions" => special_offer.redemptions.size,
        "demographics" => get_offer_demographics(special_offer),
        "time_slot_total_redemptions" => get_time_slot_total_redemptions(special_offer, params[:time_slot_dates]),
        "time_slot_total_views" => get_time_slot_total_offer_impresssions(special_offer, params[:time_slot_dates]),
        "time_slot_views_date_wise" => get_time_slot_views_date_wise(params[:time_slot_dates], special_offer),
        "time_slot_redemptions_date_wise" => get_time_slot_redemptions_date_wise(params[:time_slot_dates], special_offer),
        "time_slot_total_offer_shares" => get_time_slot_total_offer_shares(params[:time_slot_dates], special_offer),
        "time_slot_offer_shares_date_wise" => get_time_slot_offer_shares_date_wise(params[:time_slot_dates], special_offer)
      }

      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          stats: stats
        }
      }
    else
      render json: {
        code:400,
        success: false,
        message: 'special_offer_id and time_slot_dates are required.',
        data: nil
      }
    end
  end



  def get_competition_stats
    if !params[:competition_id].blank? && !params[:time_slot_dates].blank?
      competition = Competition.find(params[:competition_id])
        stats = {
          "id" => competition.id,
          "winners" => competition.competition_winners.map {|w| w.user },
          "total_entries" => competition.registrations.size,
          "demographics" =>  get_competition_demographics(competition),
          "time_slot_total_entries" => get_time_slot_total_entries(competition, params[:time_slot_dates]),
          "time_slot_total_views" => get_time_slot_total_competition_impresssions(competition, params[:time_slot_dates]),
          "time_slot_shares" => get_time_slot_total_offer_shares(params[:time_slot_dates], competition),
          "time_slot_entries_date_wise" => get_time_slot_entries_date_wise(params[:time_slot_dates],competition),
          "time_slot_views_date_wise" => get_time_slot_views_date_wise(params[:time_slot_dates], competition),
          "time_slot_shares_date_wise" => get_time_slot_offer_shares_date_wise(params[:time_slot_dates], competition)
        }
  
        render json: {
          code: 200,
          success: true,
          message: '',
          data: {
            stats: stats
          }
        }
      else
        render json: {
          code:400,
          success: false,
          message: 'competition_id and time_slot_dates are required.',
          data: nil
        }
      end
  end





  def get_dashboard

   if !params[:business_id].blank? && !params[:resource].blank? && !params[:current_time_slot_dates].blank? && !params[:before_current_time_slot_dates].blank?

    @business = User.find(params[:business_id])
     resource = params[:resource]
     business_detail = []
     business_detail << {
       "total_events" =>  @business.events.size,
       "total_competitions" => @business.competitions.size,
       "total_offers" => @business.special_offers.size.to_i + @business.passes.size.to_i,
       "total_followers" => @business.followers.size,
       "business_name" => get_full_name(@business),
       "business_logo" => @business.avatar,
     }
    case resource
      when 'events'
        events = []
     @business.events.each do |event|
           stats = []
           stats << {
          "time_slot_total_attendees" => get_time_slot_total_attendees(params[:current_time_slot_dates], event),
          "time_slot_increment_decrement_in_attendees" => get_time_slot_increment_decrement_in_attendees(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
          "time_slot_attendees_date_wise" => get_time_slot_attendees_date_wise(params[:current_time_slot_dates], event),
          "time_slot_total_views" => get_time_slot_total_views(params[:current_time_slot_dates], event),
          "time_slot_increment_decrement_in_views" => get_time_slot_increment_decrement_in_views(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
          "time_slot_event_views_date_wise" => get_time_slot_event_views_date_wise(params[:current_time_slot_dates],event),
          "time_slot_total_sold_tickets" => get_time_slot_total_sold_tickets(params[:current_time_slot_dates], event),
          "time_slot_increment_decrement_in_sold_tickets" => time_slot_increment_decrement_in_sold_tickets(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
          "time_slot_sold_tickets_date_wise" => get_time_slot_sold_tickets_date_wise(params[:current_time_slot_dates] ,event),
          "time_slot_total_interested_people" => get_time_slot_total_interested_people(params[:current_time_slot_dates], event),
          "time_slot_interested_increment_decrement" => get_time_slot_interested_increment_decrement(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
          "time_slot_total_shared_events" => get_time_slot_total_shared_events(params[:current_time_slot_dates], event),
          "time_slot_increment_decrement_in_shared_events" => get_time_slot_increment_decrement_in_shared_events(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
          "time_slot_shares_date_wise" => get_time_slot_shares_date_wise(params[:current_time_slot_dates],event),
          "time_slot_total_event_comments" => get_time_slot_total_event_comments(params[:current_time_slot_dates], event),
          "time_slot_increment_decrement_in_event_comments" => get_time_slot_increment_decrement_in_event_comments(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
          "time_slot_comments_date_wise" => get_time_slot_comments_date_wise(params[:current_time_slot_dates],event)
        }


        events << {
          "event_id" => event.id,
          "name" => event.name,
          "start_date" => event.start_date,
          "end_date" => event.end_date,
          "start_time" => event.start_time,
          "end_time" => event.end_time,
          "location" => event.location,
          "lat" => event.lat,
          "lng" => event.lng,
          "event_type" => event.event_type,
          "image" => event.image,
          "price_type" => event.price_type,
          "price" => event.price,
          "additional_media" => event.event_attachments,
          "created_at" => event.created_at,
          "updated_at" => event.updated_at,
          "stats" => stats
        }
        end #each
        render json: {
          code: 200,
          success: true,
          message: '',
          data: {
            business_detail: business_detail,
            resource: events
          }
        }
      when 'offers'
        special_offers = []
         @business.special_offers.each do |offer|
          stats = []
          stats << {
           "time_slot_total_special_offers" => get_time_slot_total_special_offers(params[:current_time_slot_dates], offer),
           "time_slot_increment_decrement_in_special_offers" =>  get_time_slot_special_offers_increment_decrement(params[:current_time_slot_dates],    params[:before_current_time_slot_dates], offer),
           "time_slot_taken_special_offers_date_wise" => get_time_slot_special_offers_date_wise(params[:current_time_slot_dates], offer),
           "time_slot_offer_views" => get_time_slot_offer_views(params[:current_time_slot_dates], offer),
           "time_slot_increment_decrement_in_offer_views" => get_time_slot_increment_decrement_in_offer_views(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
           "time_slot_views_date_wise" => get_time_slot_views_date_wise(params[:current_time_slot_dates], offer),
           "time_slot_increment_decrement_in_offer_redemptions" => get_time_slot_increment_decrement_in_offer_redemptions(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
           "time_slot_redemptions_date_wise" => get_time_slot_redemptions_date_wise(params[:current_time_slot_dates], offer),
           "time_slot_total_offer_shares" => get_time_slot_total_offer_shares(params[:current_time_slot_dates], offer),
           "time_slot_increment_decrement_in_offer_shares" => get_time_slot_increment_decrement_in_offer_shares(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
           "time_slot_offer_shares_date_wise" => get_time_slot_offer_shares_date_wise(params[:current_time_slot_dates], offer),
           "time_slot_total_ambassador_offer_shares" =>  get_time_slot_total_ambassador_offer_shares(params[:current_time_slot_dates], offer),
           "time_slot_increment_decrement_in_ambassador_offer_shares" => get_time_slot_increment_decrement_in_ambassador_offer_shares(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
           "time_slot_ambassador_offer_shares_date_wise" => get_time_slot_ambassador_offer_shares_date_wise(params[:current_time_slot_dates], offer)

          }
          special_offers << {
          id: offer.id,
          title: offer.title,
          sub_title: offer.sub_title,
          location: offer.location,
          date: offer.date,
          time: offer.time,
          lat: offer.lat,
          lng: offer.lng,
          image: offer.image.url,
          creator_name: offer.user.business_profile.profile_name,
          creator_image: offer.user.avatar,
          description: offer.description,
          validity: offer.validity,
          grabbers_count: offer.wallets.size,
          stats: stats
        }
        end #each

        render json: {
          code: 200,
          success: true,
          message: '',
          data: {
            business_detail: business_detail,
            resource: special_offers
          }
        }

      when 'competitions'
        competitions = []
        @business.competitions.each do |competition|
          stats = []
           stats << {
             "time_slot_total_competitions" =>  get_time_slot_total_competitions(params[:current_time_slot_dates], competition),
             "time_slot_competitions_increment_decrement" => get_time_slot_competitions_increment_decrement(params[:current_time_slot_dates],    params[:before_current_time_slot_dates], competition),
             "time_slot_competitions_date_wise" => get_time_slot_competitions_date_wise(params[:current_time_slot_dates], competition)
           }
          competitions << {
            id: competition.id,
            title: competition.title,
            description: competition.description,
            location: competition.location,
            start_date: competition.start_date,
            end_date: competition.end_date,
            start_time: competition.start_time,
            end_time: competition.end_time,
            price: competition.price,
            lat: competition.lat,
            lng: competition.lng,
            image: competition.image.url,
            friends_participants_count: competition.registrations.map {|reg| if(request_user.friends.include? reg.user) then reg.user end }.size,
            creator_name: competition.user.first_name + " " + competition.user.last_name,
            creator_image: competition.user.avatar,
            validity: competition.validity + "T" + competition.validity_time.strftime("%H:%M:%S") + ".000Z",
            stats: stats
          }
        end #each

        render json: {
          code: 200,
          success: true,
          message: '',
          data: {
            business_detail: business_detail,
            resource: competitions
          }
        }

      when 'passes'
      passes = []
      @business.passes.each do |pass|
        stats = []
        stats << {
          "time_slot_total_special_offers" => get_time_slot_total_passes(params[:current_time_slot_dates], pass),
          "time_slot_passes_increment_decrement" =>  get_time_slot_passes_increment_decrement(params[:current_time_slot_dates], params[:before_current_time_slot_dates], pass),
          "time_slot_passes_date_wise" => get_time_slot_passes_date_wise(params[:current_time_slot_dates], pass)
        }
        passes << {
          id: pass.id,
          title: pass.title,
          host_name: pass.event.user.first_name + " " + pass.event.user.last_name,
          host_image: pass.event.user.avatar,
          event_name: pass.event.name,
          event_id: pass.event.id,
          event_image: pass.event.image,
          event_location: pass.event.location,
          event_start_time: pass.event.start_time,
          event_end_time: pass.event.end_time,
          event_date: pass.event.start_date,
          distributed_by: distributed_by(pass),
          validity: pass.validity + " " + pass.validity_time.strftime("%H:%M:%S").to_s,
          grabbers_count: pass.wallets.size,
          stats: stats
        }
          end#each

          render json: {
            code: 200,
            success: true,
            message: '',
            data: {
              business_detail: business_detail,
              resource: passes
            }
          }

      else
        #do nothing
      end #case end
    else
      render json: {
        code: 400,
        success: false,
        message: 'business_id, current_time_slot_dates,before_current_time_slot_dates and resource are required fields.',
        data: nil
      }
    end #if

  end

  private

  ##################### attendess #######################


   def get_time_slot_total_attendees(current_time_slot_dates, event)
      @total_registrations = []
       dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
      dates_array.each do |date|
      p_date = Date.parse(date)
      @attendees = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@attendees.blank?
        @total_registrations.push(@attendees.size)
      end
     end
       get_sum_of_array_elements(@total_registrations)
   end




   def get_time_slot_increment_decrement_in_attendees(current_time_slot_dates, before_current_time_slot_dates, event)

      @current_time_slot_registrations = []
      @before_current_time_slot_registrations = []
      @increment_decreament_in_registrations = {}

      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @attendees = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@attendees.blank?
          @current_time_slot_registrations.push(@attendees.size)
        end
        end #each

        before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
        before_current_dates_array.each do |date|
          p_date = Date.parse(date)
          @attendees = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@attendees.blank?
            @before_current_time_slot_registrations.push(@attendees.size)
          end
          end #each

       @current_registrations = get_sum_of_array_elements(@current_time_slot_registrations)
       @before_registrations = get_sum_of_array_elements(@before_current_time_slot_registrations)
       @diff = @current_registrations - @before_registrations

       @increment_decreament_in_registrations['before_registrations'] = @before_registrations
       @increment_decreament_in_registrations['current_registrations'] = @current_registrations
       @increment_decreament_in_registrations['difference'] = @diff

       @increment_decreament_in_registrations

   end

   def get_time_slot_attendees_date_wise(time_slot_dates,event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }

     @time_slot_dates_stats = {}

     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date] = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size
     end# each

     @time_slot_dates_stats
   end

   ########################## views ##############################

   def get_time_slot_total_views(current_time_slot_dates, event)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end



   def get_time_slot_increment_decrement_in_views(current_time_slot_dates, before_current_time_slot_dates, event)

    @current_time_slot_views = []
    @before_current_time_slot_views = []

    @increment_decreament_in_views = {}

    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @current_time_slot_views.push(@views.size)
      end
      end #each
      before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
      before_current_dates_array.each do |date|
        p_date = Date.parse(date)
        @views = event.views.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@views.blank?
          @before_current_time_slot_views.push(@views.size)
        end
        end #each

     @current_views = get_sum_of_array_elements(@current_time_slot_views)
     @before_views = get_sum_of_array_elements(@before_current_time_slot_views)

     @increment_decreament_in_views['before_views'] = @before_views
     @increment_decreament_in_views['current_views'] = @current_views
     @increment_decreament_in_views['difference'] = @current_views - @before_views
     @increment_decreament_in_views
 end



 def get_time_slot_event_views_date_wise(time_slot_dates,event)
   dates_array = time_slot_dates.split(',').map {|s| s.to_s }
   @time_slot_dates_stats = {}
   dates_array.each do |date|
    p_date = Date.parse(date)
    @time_slot_dates_stats[date] = event.views.where(created_at: p_date.midnight..p_date.end_of_day).size

   end# each

   @time_slot_dates_stats
 end

 def get_time_slot_interested_people_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates_stats[date] = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size

  end# each

  @time_slot_dates_stats
end



   ########################### tickets ###################################
    def get_time_slot_total_sold_tickets(current_time_slot_dates, event)
      @tickets_sold = 0
      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
     if !event.ticket.blank?
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @tickets = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)

        if !@tickets.blank?
          @tickets.each do |ticket|
            @tickets_sold = @tickets_sold + ticket.quantity.to_i
          end
        end
        end #each
      end #if
        @tickets_sold
     end


   def time_slot_increment_decrement_in_sold_tickets(current_time_slot_dates, before_current_time_slot_dates, event)

      @current_tickets_sold = 0
      @before_tickets_sold = 0

      @increment_decrement_in_sold_tickets = {}

      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
     if !event.ticket.blank?
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @tickets = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)

        if !@tickets.blank?
          @tickets.each do |ticket|
            @current_tickets_sold = @current_tickets_sold + ticket.quantity.to_i
          end
        end
        end #each

        before_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
        before_dates_array.each do |date|
          p_date = Date.parse(date)
          @tickets = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)

          if !@tickets.blank?
            @tickets.each do |ticket|
              @before_tickets_sold = @before_tickets_sold + ticket.quantity.to_i
            end
          end
          end #each

      end #if
        @increment_decrement_in_sold_tickets['before_sold_tickets'] = @before_tickets_sold
        @increment_decrement_in_sold_tickets['current_sold_tickets'] = @current_tickets_sold
        @increment_decrement_in_sold_tickets['difference'] = @current_tickets_sold - @before_tickets_sold

        @increment_decrement_in_sold_tickets
     end

     def get_time_slot_sold_tickets_date_wise(time_slot_dates,event)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }
      @time_slot_dates_stats = {}
      if !event.ticket.blank?
        dates_array.each do |date|
          p_date = Date.parse(date)
          @ticket_purchases = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)
          if !@ticket_purchases.blank?
            @ticket_purchases.each do |p|
              time_slot_days.push(p.quantity)
            end
          end
          end #each
        end #if

        get_sum_of_array_elements(@time_slot_dates_stats)
    end

  ################################## interested #####################################

  def get_time_slot_total_interested_people(current_time_slot_dates, event)
    @interested_people = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @interested = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@interested.blank?
        @interested_people.push(@interested.size)
      end
      end #each
      get_sum_of_array_elements(@interested_people)
  end

  def get_time_slot_interested_increment_decrement(current_time_slot_dates, before_current_time_slot_dates, event)
    @current_time_slot_interested = []
    @before_current_time_slot_interested = []

    @increment_decreament_in_interested = {}

    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @interested = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@interested.blank?
        @current_time_slot_interested.push(@interested.size)
      end
      end #each
      before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
      before_current_dates_array.each do |date|
        p_date = Date.parse(date)
        @interested = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@interested.blank?
          @before_current_time_slot_interested.push(@interested.size)
        end
        end #each

     @current_interested = get_sum_of_array_elements(@current_time_slot_interested)
     @before_interested = get_sum_of_array_elements(@before_current_time_slot_interested)
     @diff = @current_interested - @before_interested

     @increment_decreament_in_interested['before_interested'] = @before_interested
     @increment_decreament_in_interested['current_interested'] = @current_interested
     @increment_decreament_in_interested['difference'] = @diff

     @increment_decreament_in_interested

 end

 def get_time_slot_interested_date_wise(time_slot_dates,event)
   dates_array = time_slot_dates.split(',').map {|s| s.to_s }

   @time_slot_dates = {}
   dates_array.each do |date|
    p_date = Date.parse(date)
    @time_slot_dates[date.to_date] = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size
   end# each

   @time_slot_dates
 end

################################## Special offers #####################################

 def get_time_slot_total_special_offers(current_time_slot_dates, offer)
  @taken = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @taken_offers = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@taken_offers.blank?
      @taken.push(@taken_offers.size)
    end
    end #each
    get_sum_of_array_elements(@taken)
end

def get_time_slot_special_offers_increment_decrement(current_time_slot_dates,    before_current_time_slot_dates, offer)

  @current_time_slot_special_offers = []
  @before_current_time_slot_special_offers = []

  @increment_decreament_in_special_offers = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }

  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @wallet = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@wallet.blank?
      @current_time_slot_special_offers.push(@wallet)
    end
    end #each

    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @wallet = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@wallet.blank?
        @before_current_time_slot_special_offers.push(@wallet)
      end
      end #each

   @current_special_offers = @current_time_slot_special_offers.size
   @before_special_offers = @before_current_time_slot_special_offers.size
   @diff = @current_special_offers - @before_special_offers

   @increment_decreament_in_special_offers['before_special_offers'] = @before_special_offers
   @increment_decreament_in_special_offers['current_special_offers'] = @current_special_offers
   @increment_decreament_in_special_offers['difference'] = @diff

   @increment_decreament_in_special_offers
    end

    def get_time_slot_special_offers_date_wise(time_slot_dates, offer)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }
      @time_slot_dates = {}
      dates_array.each do |date|
       p_date = Date.parse(date)
       @time_slot_dates[date.to_date] = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day).size
      end# each

      @time_slot_dates
    end

   #################################### Passes #####################################

    def get_time_slot_total_passes(current_time_slot_dates, pass)
      @taken = []
      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @taken_passes = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@taken_passes.blank?
          @taken.push(@taken_passes.size)
        end
        end #each
      get_sum_of_array_elements(@taken)
    end

    def get_time_slot_passes_increment_decrement(current_time_slot_dates,    before_current_time_slot_dates, pass)

      @current_time_slot_passes = []
      @before_current_time_slot_passes = []

      @increment_decreament_in_passes = {}

      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }

      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @wallets = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@wallets.blank?
          @current_time_slot_passes.push(@wallets.size)
        end
        end #each

        before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
        before_current_dates_array.each do |date|
          p_date = Date.parse(date)
          @wallets = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@wallets.blank?
            @before_current_time_slot_passes.push(@wallets.size)
          end
          end #each

       @current_passes = get_sum_of_array_elements(@current_time_slot_passes)
       @before_passes = get_sum_of_array_elements(@before_current_time_slot_passes)
       @diff = @current_passes - @before_passes

       @increment_decreament_in_passes['before_passes'] = @before_passes
       @increment_decreament_in_passes['current_passes'] = @current_passes
       @increment_decreament_in_passes['difference'] = @diff

       @increment_decreament_in_passes
    end

    def get_time_slot_passes_date_wise(time_slot_dates, pass)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }

      @time_slot_dates_stats = {}
      dates_array.each do |date|
       p_date = Date.parse(date)
       @time_slot_dates_stats[date.to_date] = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day).size
      end# each

      @time_slot_dates_stats
    end

      #################################### Competitions #####################################

      def get_time_slot_total_competitions(current_time_slot_dates, competition)
          @taken = []
          current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
          current_dates_array.each do |date|
          p_date = Date.parse(date)
          @competitions = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@competitions.blank?
            @taken.push(@competitions.size)
          end
          end #each
          get_sum_of_array_elements(@taken)
      end

      def get_time_slot_competitions_increment_decrement(current_time_slot_dates,    before_current_time_slot_dates, competition)

        @current_time_slot_competitions = []
        @before_current_time_slot_competitions = []

        @increment_decreament_in_competitions = {}

        current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }

        current_dates_array.each do |date|
          p_date = Date.parse(date)
          @competitions = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@competitions.blank?
            @current_time_slot_competitions.push(@competitions.size)
          end
          end #each

          before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
          before_current_dates_array.each do |date|
            p_date = Date.parse(date)
            @competitions = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day)
            if !@competitions.blank?
              @before_current_time_slot_competitions.push(@competitions.size)
            end
            end #each

         @current_competitions = get_sum_of_array_elements(@current_time_slot_competitions)
         @before_competitions = get_sum_of_array_elements(@before_current_time_slot_competitions)
         @diff = @current_competitions - @before_competitions

         @increment_decreament_in_competitions['before_competitions'] = @before_competitions
         @increment_decreament_in_competitions['current_competitions'] = @current_competitions
         @increment_decreament_in_competitions['difference'] = @diff

         @increment_decreament_in_competitions
      end

      def get_time_slot_competitions_date_wise(time_slot_dates, competition)
        dates_array = time_slot_dates.split(',').map {|s| s.to_s }

        @time_slot_dates_stats = {}
        dates_array.each do |date|
         p_date = Date.parse(date)
         @time_slot_dates_stats[date.to_date] = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day).size
        end# each

        @time_slot_dates_stats
      end

   #################################### event sharing #####################################
      def get_time_slot_total_shared_events(current_time_slot_dates, event)
        @total_shared_events = []
        current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
        current_dates_array.each do |date|
          p_date = Date.parse(date)
          @shares = event.event_shares.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@shares.blank?
            @total_shared_events.push(@shares.size)
          end
          end #each
          get_sum_of_array_elements(@total_shared_events)
      end



      def get_time_slot_increment_decrement_in_shared_events(current_time_slot_dates, before_current_time_slot_dates, event)

        @current_time_slot_shared_events = []
        @before_current_time_slot_shared_events = []

        @increment_decreament_in_shared_events = {}

        current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
        current_dates_array.each do |date|
          p_date = Date.parse(date)
          @shares = event.event_shares.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@shares.blank?
            @current_time_slot_shared_events.push(@shares.size)
          end
          end #each
          before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
          before_current_dates_array.each do |date|
            p_date = Date.parse(date)
            @shares = event.event_shares.where(created_at: p_date.midnight..p_date.end_of_day)
            if !@shares.blank?
              @before_current_time_slot_shared_events.push(@shares.size)
            end
            end #each

         @current_shares = get_sum_of_array_elements(@current_time_slot_shared_events)
         @before_shares = get_sum_of_array_elements(@before_current_time_slot_shared_events)

         @increment_decreament_in_shared_events['before_shares'] = @before_shares
         @increment_decreament_in_shared_events['current_shares'] = @current_shares
         @increment_decreament_in_shared_events['difference'] = @current_shares - @before_shares
         @increment_decreament_in_shared_events
     end


     def get_time_slot_shares_date_wise(time_slot_dates,event)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }
      @time_slot_dates_stats = {}
      dates_array.each do |date|
       p_date = Date.parse(date)
       @time_slot_dates_stats[date.to_date] = event.event_shares.where(created_at: p_date.midnight..p_date.end_of_day).size
      end# each

      @time_slot_dates_stats
    end

  #################################### event chats #####################################

  def get_time_slot_total_event_comments(current_time_slot_dates, event)
    @total_comments = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @comments = event.comments.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@comments.blank?
        @total_comments.push(@comments.size)
      end
      end #each
      get_sum_of_array_elements(@total_comments)
  end



  def get_time_slot_increment_decrement_in_event_comments(current_time_slot_dates, before_current_time_slot_dates, event)

    @current_time_slot_event_comments = []
    @before_current_time_slot_event_comments = []

    @increment_decreament_in_event_comments = {}

    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @comments = event.comments.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@comments.blank?
          @current_time_slot_event_comments.push(@comments.size)
      end
      end #each
      before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
      before_current_dates_array.each do |date|
        p_date = Date.parse(date)
        @comments = event.comments.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@comments.blank?
          @before_current_time_slot_event_comments.push(@comments.size)
        end
        end #each

     @current_comments = get_sum_of_array_elements(@current_time_slot_event_comments)
     @before_comments = get_sum_of_array_elements(@before_current_time_slot_event_comments)

     @increment_decreament_in_event_comments['before_comments'] = @before_comments
     @increment_decreament_in_event_comments['current_comments'] = @current_comments
     @increment_decreament_in_event_comments['difference'] = @current_comments - @before_comments
     @increment_decreament_in_event_comments
 end


 def get_time_slot_comments_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
    @time_slot_dates_stats[date.to_date] = event.comments.where(created_at: p_date.midnight..p_date.end_of_day).size

  end# each
  @time_slot_dates_stats
end

  #################################### offer stats new #####################################

  def get_time_slot_offer_views(current_time_slot_dates, offer)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      @time_slot_views = get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_increment_decrement_in_offer_views(current_time_slot_dates, before_current_time_slot_dates, offer)

    @current_time_slot_views = []
    @before_current_time_slot_views = []

    @increment_decreament_in_views = {}

    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @current_time_slot_views.push(@views.size)
      end
      end #each
      before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
      before_current_dates_array.each do |date|
        p_date = Date.parse(date)
        @views = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@views.blank?
          @before_current_time_slot_views.push(@views.size)
        end
        end #each

     @current_views = get_sum_of_array_elements(@current_time_slot_views)
     @before_views = get_sum_of_array_elements(@before_current_time_slot_views)

     @increment_decreament_in_views['before_views'] = @before_views
     @increment_decreament_in_views['current_views'] = @current_views
     @increment_decreament_in_views['difference'] = @current_views - @before_views
     @increment_decreament_in_views
 end

 def get_time_slot_views_date_wise(time_slot_dates, offer)
   dates_array = time_slot_dates.split(',').map {|s| s.to_s }
   @time_slot_dates_stats = {}
   dates_array.each do |date|
    p_date = Date.parse(date)
    @time_slot_dates_stats[date.to_date] = offer.views.where(created_at: p_date.midnight..p_date.end_of_day).size
   end# each

   @time_slot_dates_stats
 end


 def get_time_slot_total_offer_redemptions(current_time_slot_dates, offer)
  @total_redemptions = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @redemptions = offer.redemptions.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@redemptions.blank?
      @total_redemptions.push(@redemptions)
    end
    end #each
     get_sum_of_array_elements(@redemptions)
 end


 def get_time_slot_increment_decrement_in_offer_redemptions(current_time_slot_dates, before_current_time_slot_dates, offer)

  @current_time_slot_redemptions = []
  @before_current_time_slot_redemptions = []

  @increment_decreament_in_redemptions = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @redemptions = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@redemptions.blank?
      @current_time_slot_redemptions.push(@redemptions.size)
    end
    end #each
    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @redemptions = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@redemptions.blank?
        @before_current_time_slot_redemptions.push(@redemptions.size)
      end
      end #each

   @current_redemptions = get_sum_of_array_elements(@current_time_slot_redemptions)
   @before_redemptions = get_sum_of_array_elements(@before_current_time_slot_redemptions)

   @increment_decreament_in_redemptions['before_redemptions'] = @before_redemptions
   @increment_decreament_in_redemptions['current_redemptions'] = @current_redemptions
   @increment_decreament_in_redemptions['difference'] = @current_redemptions - @before_redemptions
   @increment_decreament_in_redemptions
end

def get_time_slot_redemptions_date_wise(time_slot_dates, offer)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates_stats[date.to_date] = offer.redemptions.where(created_at: p_date.midnight..p_date.end_of_day).size

  end# each

  @time_slot_dates_stats
end


def get_time_slot_total_offer_shares(current_time_slot_dates, offer)
  @total_shares = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@shares.blank?
      @total_shares.push(@shares.size)
    end
    end #each
     get_sum_of_array_elements(@total_shares)
 end


 def get_time_slot_increment_decrement_in_offer_shares(current_time_slot_dates, before_current_time_slot_dates, offer)

  @current_time_slot_shares = []
  @before_current_time_slot_shares = []

  @increment_decreament_in_shares = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@shares.blank?
      @current_time_slot_shares.push(@shares.size)
    end
    end #each
    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@shares.blank?
        @before_current_time_slot_shares.push(@shares.size)
      end
      end #each

   @current_shares = get_sum_of_array_elements(@current_time_slot_shares)
   @before_shares = get_sum_of_array_elements(@before_current_time_slot_shares)

   @increment_decreament_in_shares['before_shares'] = @before_shares
   @increment_decreament_in_shares['current_shares'] = @current_shares
   @increment_decreament_in_shares['difference'] = @current_shares - @before_shares
   @increment_decreament_in_shares
end


def get_time_slot_offer_shares_date_wise(time_slot_dates, offer)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates_stats[date.to_date] = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).size
  end# each

  @time_slot_dates_stats
end


def get_time_slot_total_ambassador_offer_shares(current_time_slot_dates, offer)
  @ambassador_shares = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true)
    if !@shares.blank?
     @ambassador_shares.push(@shares.size)
    end
    end #each
     get_sum_of_array_elements(@ambassador_shares)
 end


 def get_time_slot_increment_decrement_in_ambassador_offer_shares(current_time_slot_dates, before_current_time_slot_dates, offer)

  @current_time_slot_shares = []
  @before_current_time_slot_shares = []

  @increment_decreament_in_shares = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true)
    if !@shares.blank?
      @current_time_slot_shares.push(@shares.size)
     end #if !blank?
    end #each
    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true)
      if !@shares.blank?
           @before_current_time_slot_shares.push(@shares.size)
      end #if !blank?
      end #each

   @current_shares = get_sum_of_array_elements(@current_time_slot_shares)
   @before_shares = get_sum_of_array_elements(@before_current_time_slot_shares)

   @increment_decreament_in_shares['before_shares'] = @before_shares
   @increment_decreament_in_shares['current_shares'] = @current_shares
   @increment_decreament_in_shares['difference'] = @current_shares - @before_shares
   @increment_decreament_in_shares
end


def get_time_slot_ambassador_offer_shares_date_wise(time_slot_dates, offer)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)

    @time_slot_dates_stats[date.to_date] =  offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true).size

  end# each

  @time_slot_dates_stats
end


def get_sum_of_array_elements(array)
  array.inject(0){|sum,x| sum + x }
end

##################################### New stats functions ##########################33

def get_time_slot_total_redemptions(special_offer, time_slot)
   dates_array = time_slot.split(',').map {|s| s.to_s }
   @redemptions = []
   dates_array.each do |date|
      p_date = Date.parse(date)
      redemption = special_offer.redemptions.where(created_at: p_date.midnight..p_date.end_of_day)
      if !redemption.blank?
        @redemptions.push(redemption)
   end #if !blank?
   end #each
   @redemptions.size
end


def get_time_slot_total_offer_impresssions(special_offer, time_slot)
  dates_array = time_slot.split(',').map {|s| s.to_s }
  @views = []
  dates_array.each do |date|
     p_date = Date.parse(date)
     view = special_offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
     if !view.blank?
       @views.push(view)
  end #if !blank?
  end #each
  @views.size
end


def get_time_slot_total_entries(competition, time_slot)
  dates_array = time_slot.split(',').map {|s| s.to_s }
  @entries = []
  dates_array.each do |date|
     p_date = Date.parse(date)
     entry = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day)
     if !entry.blank?
       @entries.push(entry)
  end #if !blank?
  end #each
  @entries.size
end


def get_time_slot_total_competition_impresssions(competition, time_slot)
  dates_array = time_slot.split(',').map {|s| s.to_s }
  @views = []
  dates_array.each do |date|
     p_date = Date.parse(date)
     view = competition.views.where(created_at: p_date.midnight..p_date.end_of_day)
     if !view.blank?
       @views.push(view)
  end #if !blank?
  end #each
  @views.size
end


def get_time_slot_entries_date_wise(time_slot_dates,competition)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }

  @time_slot_dates = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates[date.to_date] = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day).size
  end# each

  @time_slot_dates
end

def get_event_paid_checked_in_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }

  @time_slot_dates = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates[date.to_date] =  event.tickets.where(created_at: p_date.midnight..p_date.end_of_day).where(ticket_type: 'buy').size
  end# each

  @time_slot_dates
end


def get_event_pass_checked_in_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }

  @time_slot_dates = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates[date.to_date] =  event.passes.where(created_at: p_date.midnight..p_date.end_of_day).map {|p| p.redemptions.size }.sum
  end# each

  @time_slot_dates
end


def get_pass_total_checked_in(event)
  event.passes.map {|p| p.redemptions.size }.sum
end


def get_total_paid_checked_in(event)
  event.tickets.where(ticket_type: 'buy').size
end


def get_time_slot_total_pass_checked_in(time_slot_dates, event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @checked_in = []
  dates_array.each do |date|
     p_date = Date.parse(date)
     checked_in = event.passes.redemptions.where(created_at: p_date.midnight..p_date.end_of_day)
     if !view.blank?
       @checked_in.push(checked_in)
  end #if !blank?
  end #each
  @checked_in.size
end


def get_time_slot_total_paid_checked_in(time_slot_dates, event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @checked_in = []
  dates_array.each do |date|
     p_date = Date.parse(date)
     checked_in = event.tickets.map{|t| t.ticket_purchases.where(created_at: p_date.midnight..p_date.end_of_day).size }.sum
     if !view.blank?
       @checked_in.push(checked_in)
  end #if !blank?
  end #each
  @checked_in.size
end





end
