class Api::V1::Events::Tickets::ReservationsController < Api::V1::ApiMasterController
    before_action :authorize_request

    require 'json'
    require 'pubnub'
    require 'action_view'
    require 'action_view/helpers'
    include ActionView::Helpers::DateHelper
    
    
    
    def create
        if !params[:ticket_id].blank? && !params[:user_id].blank? && !params[:start_time].blank? && !params[:end_time].blank?
             user = User.find(params[:user_id])
             ticket = Ticket.find(params[:ticket_id])
            if reservation = user.reservations.create!(user: request_user, ticket: ticket, start_time: params[:start_time], end_time: params[:end_time])
                render json: {
                code: 200,
                success: true,
                message: "ticket_id is required field",
                data: {
                    reservation: get_reservation_object(reservation)
                }
             }
            else
                render json: {
                code: 400,
                success: false,
                message: "Reservation successfully created.",
                data: nil
             }  
            end 
        else
                render json: {
                code: 400,
                success: false,
                message: "ticket_id, user_id, start_time and end_time are required fields",
                dat: nil
            } 
        end
    end



end
