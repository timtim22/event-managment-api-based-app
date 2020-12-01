class Api::V1::SpecialOffersController < Api::V1::ApiMasterController
  before_action :authorize_request, except: ['index','show']

  api :GET, '/api/v1/special_offers', 'Get special offers'

  def index
    @special_offers = []
    if request_user
    SpecialOffer.page(params[:page]).per(20).not_expired.order(created_at: "DESC").each do |offer|
     if !is_removed_offer?(request_user, offer) && !is_added_to_wallet?(offer.id)
      @special_offers << {
      id: offer.id,
      title: offer.title,
      description: offer.description,
      sub_title: offer.sub_title,
      location: offer.location,
      date: offer.date,
      time: offer.time,
      lat: offer.lat,
      lng: offer.lng,
      image: offer.image.url,
      creator_name: get_full_name(offer.user),
      creator_image: offer.user.avatar,
      validity: offer.validity.strftime(get_time_format),
      end_time: offer.time,
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: get_grabbers_friends_count(offer),
      terms_and_conditions: offer.terms_conditions,
      issued_by: get_full_name(offer.user),
      redeem_count: get_redeem_count(offer),
      quantity: offer.quantity,
    }
    end #if
    end #each
    else
      SpecialOffer.not_expired.order(created_at: "DESC").each do |offer|
        @special_offers << {
        id: offer.id,
        title: offer.title,
        description: offer.description,
        sub_title: offer.sub_title,
        location: offer.location,
        date: offer.date,
        time: offer.time,
        lat: offer.lat,
        lng: offer.lng,
        image: offer.image.url,
        creator_name: get_full_name(offer.user),
        creator_image: offer.user.avatar,
        validity: offer.validity.strftime(get_time_format),
        end_time: offer.time,
        grabbers_count: offer.wallets.size,
        is_added_to_wallet: is_added_to_wallet?(offer.id),
        grabbers_friends_count: get_grabbers_friends_count(offer),
        terms_and_conditions: offer.terms_conditions,
        issued_by: get_full_name(offer.user),
        redeem_count: get_redeem_count(offer),
        quantity: offer.quantity,
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


  api :POST, '/api/v1/special-offers/special-offer-single', 'Get a single special offer'
  param :special_offer_id, :number, :desc => "ID of the special offer", :required => true

  def special_offer_single
   if !params[:special_offer_id].blank?
    offer = SpecialOffer.find(params[:special_offer_id])
    @special_offer = {
      id: offer.id,
      title: offer.title,
      description: offer.description,
      sub_title: offer.sub_title,
      location: offer.location,
      date: offer.date,
      time: offer.time,
      lat: offer.lat,
      lng: offer.lng,
      image: offer.image.url,
      creator_name: get_full_name(offer.user),
      creator_image: offer.user.avatar,
      validity: offer.validity.strftime(get_time_format),
      end_time: offer.time,
      grabbers_count: offer.wallets.size,
      is_added_to_wallet: is_added_to_wallet?(offer.id),
      grabbers_friends_count: get_grabbers_friends_count(offer),
      terms_and_conditions: offer.terms_conditions,
      issued_by: get_full_name(offer.user),
      redeem_count: get_redeem_count(offer),
      quantity: offer.quantity,
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



  api :POST, '/api/v1/get-business-offers', 'Get Business user special offer'
  param :business_id, :number, :desc => "Business ID", :required => true

  def get_business_special_offers
    if !params[:business_id].blank?
       business = User.find(params[:business_id])
       offers = business.special_offers.not_expired.map {|offer| get_special_offer_object(offer) }

        render json: {
          code: 200,
          success:true,
          message: '',
          data: {
            special_offers: offers
          }
        }

    else
      render json: {
        code: 400,
        success:false,
        message: "business_id is required field.",
        data: nil
      }
    end
  end

  api :POST, '/api/v1/redeem-special-offer', 'Redeen a special offer'
  param :offer_id, :number, :desc => "Offer ID", :required => true
  param :redeem_code, :number, :desc => "Redeem Code", :required => true

  def redeem_it
    if !params[:redeem_code].blank? && !params[:offer_id].blank?
     @special_offer = SpecialOffer.find(params[:offer_id])
       @check = Redemption.where(offer_id: params[:offer_id]).where(offer_type: 'SpecialOffer').where(user_id: request_user.id)
   if @check.blank?
    if(@special_offer && @special_offer.redeem_code == params[:redeem_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @special_offer.id, code: params[:redeem_code], offer_type: 'SpecialOffer')

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

  api :POST, '/api/v1/special_offers/create-view', 'Create a special offer view'
  param :offer_id, :number, :desc => "Offer ID", :required => true

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


