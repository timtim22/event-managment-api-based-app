class Api::V1::TicketsController < Api::V1::ApiMasterController

  def redeem_it
    if !params[:redeem_code].blank? && !params[:event_id].blank?
     @ticket = Ticket.find_by(event_id: params[:event_id])
     @check  = Redemption.where(offer_id: @ticket.id).where(offer_type: 'Ticket').where(user_id: request_user.id)
     if @check.blank?
    if(@ticket && @ticket.redeem_code == params[:redeem_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @ticket.id, code: params[:redeem_code], offer_type: 'Ticket')
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        create_activity("redeemed Ticket", @redemption, 'Redemption', '', @ticket.title, 'post')
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
end
