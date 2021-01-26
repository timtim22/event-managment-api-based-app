class Api::V1::TicketsController < Api::V1::ApiMasterController

  api :POST, '/api/v1/events/redeem-ticket', 'Redeem Ticket'
  param :event_id, :number, :desc => "Event ID", :required => true
  param :redeem_code, :string, :desc => "Redeem ID", :required => true

  def redeem_it
    if !params[:redeem_code].blank? && !params[:event_id].blank?
     @ticket = Ticket.find_by(event_id: params[:event_id])
     @check  = Redemption.where(offer_id: @ticket.id).where(offer_type: 'Ticket').where(user_id: request_user.id)
     if @check.blank?
    if(@ticket && @ticket.redeem_code == params[:redeem_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @ticket.id, code: params[:redeem_code], offer_type: 'Ticket')
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        #create_activity("redeemed Ticket", @redemption, 'Redemption', '', @ticket.title, 'post')
      render json: {
        code: 200,
        success: true,
        message: "Ticket redeemed.",
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "Ticket was not redeemed.",
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: "Redeem code doesn't match",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "Ticket is already redeemed",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "event_id and redeem_code are required fields.",
      data: nil
    }
  end
  end

  api :POST, '/api/v1/event/get-tickets', 'Get event Tickets'
  param :event_id, :number, :desc => "Event ID", :required => true

  def get_tickets
    if !params[:event_id].blank?
       @event = Event.find(params[:event_id])
       @tickets = []
       @event.tickets.each do |ticket|
         @tickets << {
           id: ticket.id,
           title: ticket.title,
           price: ticket.price,
           sold_out: sold_out?(ticket),
           ticket_type: ticket.ticket_type,
           quantity: ticket.quantity,
           per_head: ticket.per_head,
           event_name: ticket.event.name,
           event_location: ticket.event.location,
           event_start_time: ticket.event.start_time,
           event_date: ticket.event.start_date,
           validity: ticket.event.end_date,
           is_expired: event_expired?(ticket.event)
         }
       end

       render json: {
         code: 200,
         success: true,
         message: '',
         data: {
           tickets: @tickets
         }
       }
    else
      render json: {
        code: 400,
        success: false,
        message: 'event_id is required field.',
        data: nil
      }
    end
  end


  private

  def sold_out?(ticket)
    ticket.quantity.to_i == 0
  end


end
