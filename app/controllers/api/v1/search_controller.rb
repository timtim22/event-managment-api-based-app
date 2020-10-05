class  Api::V1::SearchController < Api::V1::ApiMasterController
  before_action :force_json, only: [:search_friends]
 
  def add_friends_page
    render  :add_friends
  end
   
  def search_events
  
     search_base_validate = false
     @data = []
     if !params[:search_bases].blank?
      filters = ['name', 'free', 'pass','under_price', 'over_price', 'location']
      submitted_search_bases = params[:search_bases]
     
      submitted_search_bases.each do |base|
         hash = {}
         hash = base
        if filters.include? base[:base]
          search_base_validate = true #can be used for validation purpose
          search_base = base[:base]
          case search_base
          when "name"
            @q = Event.ransack(name_cont: base[:search_term])
            @events = @q.result(distinct: true)
            if !@events.blank?
             @events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          when "free"
           @events = Ticket.where(ticket_type: 'free').map {|ticket| ticket.event  }
            if !@events.blank?
             @events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          when "pass"
            @events = Pass.all.map {|pass| pass.event }
            if !@events.blank?
              @events.map {|event| @data.push(get_simple_event_object(event)) }
            end   
          when "under_price"
            @buy_events = Ticket.where(ticket_type: 'buy').where("price < ?", base[:search_term]).map {|ticket| ticket.event  }
            if !@buy_events.blank?
              @buy_events.map {|event| @data.push(get_simple_event_object(event)) }
            end 
  
             @pay_at_door_events = Ticket.where(ticket_type: 'pay_at_door').where("end_price < ?", base[:q]).map {|ticket| ticket.event  }
            if !@pay_at_door_events.blank?
              @pay_at_door_events.map {|event| @data.push(get_simple_event_object(event)) }
            end 
  
          when "over_price"
            @buy_events = Ticket.where(ticket_type: 'buy').where("price > ?", base[:search_term]).map {|ticket| ticket.event  }
            if !@buy_events.blank?
              @buy_events.map {|event| @data.push(get_simple_event_object(event)) }
            end 
             @pay_at_door_events = Ticket.where(ticket_type: 'pay_at_door').where("end_price > ?", 
            base[:search_term]).map {|ticket| ticket.event  }
            if !@pay_at_door_events.blank?
              @pay_at_door_events.map {|event| @data.push(get_simple_event_object(event)) }
            end 
          when "location"
            @q = Event.ransack(location_cont: base[:search_term])
            @events = @q.result(distinct: true)
            if !@events.blank?
              @events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          else
            'do nothing for now'
          end #switch
        end #if  
      end #each
      render json: {
        code: 200,
        success: true,
        message: '',
        data:  {
          result: @data
        }
      } 
     else
      render json: {
        code: 400,
        success: false,
        message: "search_bases is requried field and please choose one or multiple search base(s) among allowed search bases 'name', 'free', 'pass','under_price', 'over_price', 'location' ",
        data: nil
      }
    end
  end #func




  private 
   def force_json
     request.format = :json
   end
end
 