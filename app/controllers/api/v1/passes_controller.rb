class Api::V1::PassesController < Api::V1::ApiMasterController
 
  # def index
  #   @passes = current_user.passes.order(created_at: "ASC")
  # end

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
    if !params[:redeem_code].blank? && !params[:event_id].blank?
     @pass = Pass.find_by(event_id: params[:event_id])
     @check  = Redemption.where(offer_id: @pass.id).where(offer_type: 'Pass').where(user_id: request_user.id)
     if @check.blank?
    if(@pass && @pass.redeem_code == params[:redeem_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @pass.id, code: params[:redeem_code], offer_type: 'Pass')
      @pass.is_redeemed = true
      @pass.number_of_passes = @pass.number_of_passes - 1;
      @pass.save
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        create_activity("redeemed pass", @redemption, 'Redemption', '', @pass.title, 'post')
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
          if @ambassador.is_ambassador ==  true #if user is an ambassador
          @ambassador.earning = @ambassador.earning + @pass.ambassador_rate.to_i
          @ambassador.save
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
      message: "event_id and redeem_code are required fields.",
      data: nil
    }
  end
  end


  private

  
  #  def pass_params
  #   params.permit(:title,:description, :validity)
  #  end

end
