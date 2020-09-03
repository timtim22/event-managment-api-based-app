class Api::V1::SpecialOffersController < Api::V1::ApiMasterController
  before_action :authorize_request, except: ['index','show']

  def index
    @special_offers = []
    if request_user
    SpecialOffer.not_expired.order(created_at: "DESC").each do |offer|
     if !is_removed_offer?(request_user, offer)
      @special_offers << {
      id: offer.id,
      title: offer.title,
      sub_title: offer.sub_title,
      location: offer.location,
      date: offer.date,
      time: offer.time,
      lat: offer.lat,
      lng: offer.lng,
      image: offer.image.url,
      creator_name: User.get_full_name(offer.user),
      creator_image: offer.user.avatar,
      description: offer.description,
      validity: offer.validity.strftime(get_time_format),
      end_time: offer.time.strftime(get_time_format), 
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: get_grabbers_friends_count(offer)
    }
    end #if
    end #each
    else
      SpecialOffer.not_expired.order(created_at: "DESC").each do |offer|
        @special_offers << {
        id: offer.id,
        title: offer.title,
        sub_title: offer.sub_title,
        location: offer.location,
        date: offer.date,
        time: offer.time,
        lat: offer.lat,
        lng: offer.lng,
        image: offer.image.url,
        creator_name: User.get_full_name(offer.user),
        creator_image: offer.user.avatar,
        description: offer.description,
        validity: offer.validity.strftime(get_time_format),
        end_time: offer.time.strftime(get_time_format), 
        grabbers_count: offer.wallets.size,
        is_added_to_wallet: is_added_to_wallet?(offer.id),
        grabbers_friends_count: get_grabbers_friends_count(offer)
      }
      end #each
    end#if
    render json:  {
      code: 200,
      success: true,
      message: '',
      data:  {
        special_offers: @special_offers
      }
    }
  end

  def new
    @special_offer = SpecialOffer.new
  end

  def show
    @special_offer = SpecialOffer.find(params[:id])
  end

  def create
    @special_offer = SpecialOffer.new #instantiated to avoid undefine error in case of form errors
    ids = params['event_ids']
    success = false
    if !ids.blank?
    ids.each do |id|
      @special_offer = SpecialOffer.new
      @special_offer.title = params[:title]
      @special_offer.description = params[:description]
      @special_offer.event_id = id
      @special_offer.user = current_user
      @special_offer.redeem_code = params[:redeem_code]
      @special_offer.is_redeemed = false
      @special_offer.terms_conditions = params[:terms_conditions]
      @special_offer.validity = params[:validity]
      if @special_offer.save
        success = true
      else
        success = false
      end
    end #each

    if success
      flash[:notice] = "special_offer created successfully."
      redirect_to admin_special_offers_path
    else
        render :new
    end
  else
    flash.now[:alert_danger] = "No event is selected."
    render :new
  end
   
  end

  def edit
    @special_offer = SpecialOffer.find(params[:id])
  end


  def update
    @special_offer = SpecialOffer.find(params[:id]) #instantiated to avoid undefine error in case of form errors
    ids = params['event_ids']
    success = false
    if !ids.blank?
    ids.each do |id|
      @special_offer.title = params[:title]
      @special_offer.description = params[:description]
      @special_offer.event_id = id
      @special_offer.terms_conditions = params[:terms_conditions]
      @special_offer.validity = params[:validity]
      if @special_offer.save
        success = true
      else
        success = false
      end
    end #each

    if success
      flash[:notice] = "special offer updated successfully."
      redirect_to admin_special_offers_path
    else
        render :edit
    end
  else
    flash.now[:alert_danger] = "No event is selected."
    render :new
  end
   
  end

  def destroy
    @special_offer = SpecialOffer.find(params[:id])
    if @special_offer.destroy
      redirect_to admin_special_offers_path, :notice => "Special offer deleted successfully."
    else
      flash[:alert_danger] = "Special offer deletion failed."
      redirect_to admin_special_offers_path
    end
  end

  def redeem_it
    if !params[:redeem_code].blank? && !params[:offer_id].blank?
     @special_offer = SpecialOffer.find(params[:offer_id])
       @check = Redemption.where(offer_id: params[:offer_id]).where(offer_type: 'SpecialOffer').where(user_id: request_user.id)
   if @check.blank?
    if(@special_offer && @special_offer.redeem_code == params[:redeem_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @special_offer.id, code: params[:redeem_code], offer_type: 'SpecialOffer')
      @special_offer.is_redeemed = true
      @special_offer.save
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        create_activity("redeemed special offer", @redemption, 'Redemption', '', @special_offer.title, 'post', 'redeem_special_offer')
        #ambassador program: also add earning if the pass is shared by an ambassador
        @shared_offers = []
        @forwardings = OfferForwarding.all.each do |forward|
          @shared_offers.push(forward.offer)
        end
    
        @sharings = OfferShare.all.each do |share|
          @shared_offers.push(share.offer)
        end
    
        if @shared_offers.include? @special_offer
          @share = OfferForwarding.find_by(offer_id: @special_offer.id)
          if @share.blank?
           @share = OfferShare.find_by(offer_id: @special_offer.id)
          end
          @ambassador = @share.user
          if @ambassador.profile.is_ambassador ==  true #if user is an ambassador
          @ambassador.profile.update!(earning: @ambassador.profile.earning + @special_offer.ambassador_rate.to_i)
          end
        end

      render json: {
        code: 200,
        success: true,
        message: "Special offer redeemed.",
        data: nil
      }      
    else
      render json: {
        code: 400,
        success: false,
        message: "Special offer was not redeemed.",
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
      message: "Offer is already redeemed.",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "offer_id and redeem_code are required fields.",
      data: nil
    }
  end
  end


  def create_view
    if !params[:offer_id].blank?
      offer = SpecialOffer.find(params[:offer_id])
      if view = offer.views.create!(user_id: request_user.id)
        render json: {
          code: 200,
          success: true,
          message: 'Offer view successfully created.',
          data: nil
        }
      else
        render json: {
          code: 400,
          success: false,
          message: 'Offer view creation failed.',
          data: nil
        }
      end
    else
       render json: {
         code: 400,
         success: false,
         message: 'offer_id is requied field.'
       }
      
    end
  end



  private

  def get_friend_grabbers

  end

  def is_added_to_wallet?(special_offer_id)
   if request_user
    wallet = request_user.wallets.where(offer_id: special_offer_id).where(offer_type: 'SpecialOffer')
    if !wallet.blank?
      true
    else
      false
    end
  else
    false
  end
  end





end


