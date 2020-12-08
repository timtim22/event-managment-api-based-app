class Dashboard::Api::V1::DashboardController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request
  before_action :checkout_logout
  before_action :business


  def get_dashboard_stats
    if !params[:business_id].blank? && !params[:current_time_slot_dates].blank?

      @business = User.find(params[:business_id])

      e = []
      @business.events.each do |event|
      e << {
        # "time_slot_total_event_views" => get_time_slot_total_event_views(params[:current_time_slot_dates], event)
        "time_slot_event_views_date_wise" => get_time_slot_event_views_date_wise(params[:current_time_slot_dates],event)
        # "time_slot_total_event_comments" => get_time_slot_total_event_comments(params[:current_time_slot_dates], event),
        # "time_slot_total_shared_events" => get_time_slot_total_shared_events(params[:current_time_slot_dates], event),
        # "time_slot_total_attendees" => get_time_slot_total_attendees(params[:current_time_slot_dates], event),
        # "time_slot_total_interested_people" => get_time_slot_total_interested_people(params[:current_time_slot_dates], event)
      }
    end

    o = []
    @business.special_offers.each do |offer|
      o << {
        # "time_slot_offer_views" => get_time_slot_offer_views(params[:current_time_slot_dates], offer),
        "time_slot_views_date_wise" => get_time_slot_views_date_wise(params[:current_time_slot_dates], offer)

      }
    end

    stats = []
    stats << {
      event_date_wise: e,
      offer_date_wise: o
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
        code: 400,
        success: false,
        message: 'business_id, current_time_slot_dates and before_current_time_slot_dates.',
        data: nil
      }
    end #if
   # def total_events
end
   # end
   private

   def get_time_slot_total_event_views(current_time_slot_dates, event)
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


  def get_time_slot_views_date_wise(time_slot_dates, offer)
   dates_array = time_slot_dates.split(',').map {|s| s.to_s }
   @time_slot_dates_stats = {}
   dates_array.each do |date|
    p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = offer.views.where(created_at: p_date.midnight..p_date.end_of_day).size
   end# each

   @time_slot_dates_stats
 end

   def get_time_slot_competition_views(current_time_slot_dates, competition)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = competition.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      @time_slot_views = get_sum_of_array_elements(@total_views)
   end





    def get_time_slot_event_views_date_wise(time_slot_dates,event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.views.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

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

   def business
    business = request_user
   end

   def get_sum_of_array_elements(array)
    array.inject(0){|sum,x| sum + x }
  end


end
