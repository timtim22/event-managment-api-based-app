class Api::V1::Events::Passes::PassesController < Api::V1::ApiMasterController

  api :POST, '/api/v1/events/passes/get-list', 'Get a single pass'
  param :event_id, :number, :desc => "ID of the event", :required => true


  def index
    if !params[:event_id].blank?
      child_event = ChildEvent.find(params[:event_id])
      @event = child_event.event
      @passes = []
      passes = Pass.where(event_id: @event.id).page(params[:page]).per(30)
      if !passes.blank?
        passes.each do |pass|
         if request_user
          if !is_removed_pass?(request_user, pass)
            @passes << {
              id: pass.id,
              title: pass.title,
              description: pass.description,
              host_name: get_full_name(@event.user),
              host_image:@event.user.avatar,
              event_title:@event.title,
              event_image:@event.image,
              pass_type: pass.pass_type,
              event_location:jsonify_location(@event.location),
              event_date:@event.start_time,
              event_start_time:@event.start_time,
              event_end_time:@event.end_time,
              is_added_to_wallet: is_added_to_wallet?(pass.id),
              grabbers_count: pass.wallets.size,
              validity: pass.event.start_time,
              description: pass.description,
              issued_by: get_full_name(pass.user),
              redeem_count: get_redeem_count(pass),
              quantity: pass.quantity
            }
          end
        else
          @passes << {
            id: pass.id,
            title: pass.title,
            description: pass.description,
            host_name:get_full_name(@event.user),
            host_image:@event.user.avatar,
            event_title:@event.title,
            event_image:@event.image,
            pass_type: pass.pass_type,
            event_location:jsonify_location(@event.location),
            event_date:@event.start_time,
            event_start_time:@event.start_time,
            event_end_time:@event.end_time,
            is_added_to_wallet: is_added_to_wallet?(pass.id),
            grabbers_count: pass.wallets.size,
            description: pass.description,
            issued_by: get_full_name(pass.user),
            validity: pass.event.start_time,
            redeem_count: get_redeem_count(pass),
            quantity: pass.quantity
          }
         end
        end#each
      end#if
      render json: {
        code: 200,
        success: true,
        message: "",
        data: {
          passes: @passes
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

    api :POST, '/api/v1/events/passes/show', 'View a pass'
    param :pass_id, :number, :desc => "ID of the pass", :required => true


  def pass_single
    if !params[:pass_id].blank?
     pass = Pass.find(params[:pass_id])
     @pass = {
        id: pass.id,
        title: pass.title,
        description: pass.description,
        host_name:pass.event.user.business_profile.profile_name,
        host_image:pass.event.user.avatar,
        event_title:pass.event.title,
        event_image:pass.event.image,
        event_location: jsonify_location(pass.event.location),
        event_date:pass.event.start_time,
        event_start_time: pass.event.start_time,
        event_end_time:pass.event.end_time,
        is_added_to_wallet: is_added_to_wallet?(pass.id),
        validity: pass.event.start_time,
        grabbers_count: pass.wallets.size,
        description: pass.description,
        issued_by: get_full_name(pass.user),
        redeem_count: get_redeem_count(pass),
        quantity: pass.quantity,
        remaining_passes_count: get_redeem_remaining_count(pass)
     }

     render json: {
       code: 200,
       success: true,
       message: '',
       data: {
         pass: @pass
       }
     }
   else
     render json: {
       code: 400,
       success: false,
       message: 'pass_id is required field.',
       data: nil
     }
   end
   end

  api :POST, '/api/v1/events/passes/redeem', 'To redeem a pass'
  param :pass_id, :number, :desc => "pass id", :required => true
  param :qr_code, String, :desc => "Redeem Code", :required => true

  def redeem_it
    if !params[:qr_code].blank? && !params[:pass_id].blank?
     @pass = Pass.find(params[:pass_id])
     @check  = Redemption.where(offer_id: @pass.id).where(offer_type: 'Pass').where(user_id: request_user.id)
     if @check.blank?
    if(@pass && @pass.event.qr_code == params[:qr_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @pass.id, code: params[:qr_code], offer_type: 'Pass')
      @pass.quantity = @pass.quantity - 1;
      @pass.save
       request_user.wallets.where(offer: @pass).first.update!(is_redeemed: true)
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        #create_activity(request_user, "redeemed pass", @redemption, 'Redemption', '', @pass.title, 'post', 'redeem_pass')
        #ambassador program: also add earning if the pass is shared by an ambassador
        @shared_offers = []
        @forwardings = OfferForwarding.all.each do |forward|
          @shared_offers.push(forward.offer)
        end

        @sharings = OfferShare.all.each do |share|
          @shared_offers.push(share.offer)
        end

        if @shared_offers.include? @pass
          @share = OfferForwarding.find_by(offer_id: @pass.id)
          if @share.blank?
           @share = OfferShare.find_by(offer_id: @pass.id)
          end
          
          @ambassador = @share.user
          if @ambassador.profile.is_ambassador ==  true #if user is an ambassador
           @ambassador.profile.update!(earning: '3') #should be change when ambassador schema/program will be updated. + @pass.ambassador_rate.to_i)
          end
        end

      render json: {
        code: 200,
        success: true,
        message: "Pass redeemed.",
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "Pass was not redeemed.",
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
      message: "Pass is already redeemed",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "pass_id and qr_code are required fields.",
      data: nil
    }
  end
  end

  api :POST, '/api/v1/events/passes/create-impression', 'Create an impression'
  param :pass_id, Integer, :desc => "Pass ID", :required => true

  def create_impression
    if !params[:pass_id].blank?
      pass = Pass.find(params[:pass_id])
      if view = pass.views.create!(user_id: request_user.id, business_id: pass.user.id)
        render json: {
          code: 200,
          success: true,
          message: 'View successfully created.',
          data: nil
        }
      else
        render json: {
          code: 400,
          success: false,
          message: 'View creation failed.',
          data: nil
        }
      end
    else
       render json: {
         code: 400,
         success: false,
         message: 'pass_id is requied field.'
       }

    end
  end


  private


  #  def pass_params
  #   params.permit(:title,:description, :validity)
  #  end

end
