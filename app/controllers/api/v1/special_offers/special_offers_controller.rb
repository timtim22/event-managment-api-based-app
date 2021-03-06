class Api::V1::SpecialOffers::SpecialOffersController < Api::V1::ApiMasterController
  before_action :authorize_request, except: ['get_list','show']

  

  api :GET, '/api/v1/special_offers/get-list', 'Get all special offers'

  def get_list
    @special_offers = []
    if request_user
    SpecialOffer.page(params[:page]).per(20).upcoming.active.order(created_at: "DESC").each do |offer|
     if !is_removed_offer?(request_user, offer) && !is_added_to_wallet?(offer.id)
      @special_offers << {
      id: offer.id,
      title: offer.title,
      description: offer.description,
      sub_title: offer.sub_title,
      start_time: offer.start_time,
      end_time: offer.end_time,
      lat: offer.lat,
      lng: offer.lng,
      image: offer.image.url,
      creator_name: get_full_name(offer.user),
      creator_image: offer.user.avatar,
      validity: offer.end_time,
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: get_grabbers_friends_count(offer),
      terms_and_conditions: offer.terms_conditions,
      ambassador_rate: offer.ambassador_rate,
      issued_by: get_full_name(offer.user),
      redeem_count: get_redeem_count(offer),
      participating_locations: offer.redemptions.map { |e| jsonify_location(e.user.location)},
      quantity: offer.quantity,
      limited: offer.limited,
      over_18: offer.over_18,
      outlets: offer.outlets.map { |e| jsonify_location(e.outlet_address)}
    }
    end #if
    end #each
    else
      SpecialOffer.upcoming.active.order(created_at: "DESC").each do |offer|
        @special_offers << {
        id: offer.id,
        title: offer.title,
        description: offer.description,
        sub_title: offer.sub_title,
        start_time: offer.start_time,
        end_time: offer.end_time,
        lat: offer.lat,
        lng: offer.lng,
        image: offer.image.url,
        creator_name: get_full_name(offer.user),
        creator_image: offer.user.avatar,
        validity: offer.end_time.strftime(get_time_format),
        grabbers_count: offer.wallets.size,
        is_added_to_wallet: is_added_to_wallet?(offer.id),
        grabbers_friends_count: get_grabbers_friends_count(offer),
        terms_and_conditions: offer.terms_conditions,
        ambassador_rate: offer.ambassador_rate,
        issued_by: get_full_name(offer.user),
        redeem_count: get_redeem_count(offer),
        participating_locations: offer.redemptions.map { |e| jsonify_location(e.user.location)},
        quantity: offer.quantity,
        limited: offer.limited,
        over_18: offer.over_18,
        outlets: offer.outlets.map { |e| jsonify_location(e.outlet_address)},
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


  api :POST, '/api/v1/special-offers/show', 'Get a single special offer'
  param :special_offer_id, :number, :desc => "ID of the special offer", :required => true

  def show
   if !params[:special_offer_id].blank?
    offer = SpecialOffer.find(params[:special_offer_id])
    @special_offer = {
      id: offer.id,
      title: offer.title,
      description: offer.description,
      sub_title: offer.sub_title,
      outlets: offer.outlets.map { |e| jsonify_location(e.outlet_address)},
      start_time: offer.start_time,
      end_time: offer.end_time,
      lat: offer.lat,
      lng: offer.lng,
      image: offer.image.url,
      creator_name: get_full_name(offer.user),
      creator_image: offer.user.avatar,
      validity: offer.end_time.strftime(get_time_format),
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: get_grabbers_friends_count(offer),
      terms_and_conditions: offer.terms_conditions,
      issued_by: get_full_name(offer.user),
      participating_locations: offer.redemptions.map { |e| jsonify_location(e.user.location)},
      ambassador_rate: offer.ambassador_rate,
      redeem_count: get_redeem_count(offer),
      quantity: offer.quantity,
      over_18: offer.over_18
    }

    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        special_offer: @special_offer
      }
    }
  else
    render json: {
      code: 400,
      success: false,
      message: 'special_offer_id is required field.',
      data: nil
    }
  end
  end



 
  api :POST, '/api/v1/special_offers/redeem', 'Redeem a special offer'
  param :qr_code, String, :desc => "ID of the special offer", :required => true



  def redeem_it
    if !params[:qr_code].blank? && !params[:offer_id].blank?
     @special_offer = SpecialOffer.find(params[:offer_id])
       @check = Redemption.where(offer_id: params[:offer_id]).where(offer_type: 'SpecialOffer').where(user_id: request_user.id)
   if @check.blank?
    if(@special_offer && @special_offer.qr_code == params[:qr_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @special_offer.id, code: params[:qr_code], offer_type: 'SpecialOffer')

        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        #create_activity("redeemed special offer", @redemption, 'Redemption', '', @special_offer.title, 'post', 'redeem_special_offer')
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
          if is_ambassador?(@ambassador)#if user is an ambassador
          @ambassador.profile.update!(earning: '3') #should be change when ambassador schema/program will be updated..to_i + @special_offer.ambassador_rate)
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
      message: "offer_id and qr_code are required fields.",
      data: nil
    }
  end
  end





  api :POST, '/api/v1/special_offers/create-impression', 'Create a special offer impression'
  param :offer_id, :number, :desc => "Offer ID", :required => true

  def create_impression
    if !params[:offer_id].blank?
      offer = SpecialOffer.find(params[:offer_id])
      if view = offer.views.create!(user_id: request_user.id, business_id: offer.user.id)
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


