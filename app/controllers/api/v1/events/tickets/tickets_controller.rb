class Api::V1::Events::Tickets::TicketsController < Api::V1::ApiMasterController

  api :POST, '/api/v1/events/tickets/redeem', 'Redeem Ticket'
  param :ticket_id, :number, :desc => "Event ID", :required => true
  param :qr_code, String, :desc => "Redeem code", :required => true

  def redeem_it
    if !params[:qr_code].blank? && !params[:ticket_id].blank?
     @ticket = Ticket.find(params[:ticket_id])
     @check  = Redemption.where(offer_id: @ticket.id).where(offer_type: 'Ticket').where(user_id: request_user.id)
     if @check.blank?
    if(@ticket && @ticket.event.qr_code == params[:qr_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @ticket.id, code: params[:qr_code], offer_type: 'Ticket')
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
      message: "event_id and qr_code are required fields.",
      data: nil
    }
  end
  end


  api :POST, '/api/v1/events/tickets/get-list', 'Get event tickets list'
  param :event_id, String, :desc => "Event ID", :required => true

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
           event_title: ticket.event.title,
           event_location: jsonify_location(ticket.event.location),
           event_date: ticket.event.start_time,
           validity: ticket.event.end_time,
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
