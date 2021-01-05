class Dashboard::Api::V1::DashboardController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request
  before_action :checkout_logout
  before_action :business


  def get_dashboard_stats
    if !params[:business_id].blank? && !params[:current_time_slot_dates].blank?

      @business = User.find(params[:business_id])

      stats = []
      @business.events.each do |event|
      stats << {
        "total_going" => get_time_slot_total_going(params[:current_time_slot_dates], event),
        "total_going_date_wise" => get_time_slot_going_date_wise(params[:current_time_slot_dates], event),
        "total_maybe" => get_time_slot_total_maybe(params[:current_time_slot_dates], event),
        "total_maybe_date_wise" => get_time_slot_maybe_date_wise(params[:current_time_slot_dates], event)
      }
    end

    stats << {
        "total_events" => get_time_slot_total_events(params[:current_time_slot_dates], @business),
        "total_passes" => get_time_slot_total_passes(params[:current_time_slot_dates], @business),
        "total_special_offers" => get_time_slot_total_special_offers(params[:current_time_slot_dates], @business),
        "total_competitions" => get_time_slot_total_competitions(params[:current_time_slot_dates], @business),
        "total_ambassadors" => get_time_slot_total_ambassadors(params[:current_time_slot_dates], @business),
        "total_views" => get_time_slot_total_views(params[:current_time_slot_dates], @business),
        "total_views_date_wise" => get_time_slot_views_date_wise(params[:current_time_slot_dates], @business),
        "total_comments" => get_time_slot_total_comments(params[:current_time_slot_dates], @business),
        "total_comments_date_wise" => get_time_slot_comments_date_wise(params[:current_time_slot_dates], @business),
        "total_followers" => get_time_slot_total_followers(params[:current_time_slot_dates], @business),
        "total_followers_date_wise" => get_time_slot_followers_date_wise(params[:current_time_slot_dates], @business),
        "total_shares" => get_time_slot_total_shares(params[:current_time_slot_dates], @business),
        "total_shares_date_wise" => get_time_slot_shares_date_wise(params[:current_time_slot_dates], @business)
    }
    render json: {
      code: 200,
      success: true,
      message: 'Dashboard Stats',
      data: {
        stats: stats
      }
        }
  else
      render json: {
        code: 400,
        success: false,
        message: 'business_id and current_time_slot_dates are required.',
        data: nil
      }
    end #if
   # def total_events
end
   # end



  def get_event_stats

  end


  
   private

  def get_time_slot_total_events(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.events.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_passes(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.passes.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_special_offers(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.special_offers.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_competitions(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.competitions.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_ambassadors(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.ambassadors.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

   def get_time_slot_total_views(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.business_views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end


   def get_time_slot_views_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.business_views.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_comments(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.comments.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_comments_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.comments.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_followers(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.followers.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_followers_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.followers.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_going(current_time_slot_dates, event)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_going_date_wise(time_slot_dates, event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_maybe(current_time_slot_dates, event)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_maybe_date_wise(time_slot_dates, event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_shares(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.business_shares.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_shares_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.business_shares.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def business
    business = request_user
   end

   def get_sum_of_array_elements(array)
    array.inject(0){|sum,x| sum + x }
  end


end
