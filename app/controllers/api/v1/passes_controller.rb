class Api::V1::PassesController < Api::V1::ApiMasterController
 
  def index
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
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
              host_name:@event.user.business_profile.profile_name,
              host_image:@event.user.avatar,
              event_name:@event.name,
              event_image:@event.image,
              event_location:@event.location,
              event_start_time:@event.start_time,
              event_end_time:@event.end_time,
              event_date:@event.start_date,
              is_added_to_wallet: is_added_to_wallet?(pass.id),
              validity: pass.validity.strftime(get_time_format),
              terms_and_conditions: pass.terms_conditions,
              grabbers_count: pass.wallets.size,
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
            host_name:@event.user.business_profile.profile_name,
            host_image:@event.user.avatar,
            event_name:@event.name,
            event_image:@event.image,
            event_location:@event.location,
            event_start_time:@event.start_time,
            event_end_time:@event.end_time,
            event_date:@event.start_date,
            is_added_to_wallet: is_added_to_wallet?(pass.id),
            validity: pass.validity.strftime(get_time_format),
            terms_and_conditions: pass.terms_conditions,
            grabbers_count: pass.wallets.size,
            description: pass.description,
            issued_by: get_full_name(pass.user),
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

  # def new
  #   @pass = Pass.new
  # end

  # def edit
  #   @pass = Pass.find(params[:id])
  # end

  # def update
  #   @pass = Pass.find(params[:id])
  # end

  # def create
  #   @pass = Pass.new #instantiated to avoid undefine error in case of form errors
  #   ids = params['event_ids']
  #   success = false
  #   if !ids.blank?
  #   ids.each do |id|
  #     @pass = Pass.new
  #     @pass.title = params[:title]
  #     @pass.description = params[:description]
  #     @pass.event_id = id
  #     @pass.user_id = current_user.id,
  #     @pass.redeem_code = params[:redeem_code]
  #     @pass.validity = params[:validity]
  #     if @pass.save
  #       success = true
  #     else
  #       success = false
  #     end
  #   end #each

  #   if success
  #     flash[:notice] = "Pass created successfully."
  #     redirect_to admin_passes_path
  #   else
  #       render :new
  #   end
  # else
  #   flash.now[:alert_danger] = "No event is selected."
  #   render :new
  # end
   
  # end

  # def destroy
  #   @pass = Pass.find(params[:id])
  # end

  def redeem_it
    if !params[:redeem_code].blank? && !params[:pass_id].blank?
     @pass = Pass.find(params[:pass_id])
     @check  = Redemption.where(offer_id: @pass.id).where(offer_type: 'Pass').where(user_id: request_user.id)
     if @check.blank?
    if(@pass && @pass.redeem_code == params[:redeem_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @pass.id, code: params[:redeem_code], offer_type: 'Pass')
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
          @ambassador.profile.update!(earning:  @ambassador.profile.earning + @pass.ambassador_rate.to_i)
        
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
      message: "pass_id and redeem_code are required fields.",
      data: nil
    }
  end
  end


  def create_view
    if !params[:pass_id].blank?
      pass = Pass.find(params[:pass_id])
      if view = pass.views.create!(user_id: request_user.id)
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
