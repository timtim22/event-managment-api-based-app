class Api::V1::NewsFeedsController < Api::V1::ApiMasterController


  def get_business_news_feeds

    if !params[:business_id].blank?
       business_id = params[:business_id]
       @news_feeds = User.find(business_id).news_feeds.page(params[:page]).per(10) 
       render json: {
        code: 200,
        success: true,
        message: 'business_id is required field.',
        data: {
          data: @news_feeds
        }
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'business_id is required field.',
        data: nil
      }
    end
  end


end
