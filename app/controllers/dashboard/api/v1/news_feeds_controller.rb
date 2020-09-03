class Dashboard::Api::V1::NewsFeedsController < Dashboard::Api::V1::ApiMasterController

  before_action :set_news_feed, only: ['show','edit', 'destroy']

  def index
    @news_feeds = current_user.news_feeds.order(:created_at => 'DESC').page(params[:page])
  end


  def new
    @news_feed = NewsFeed.new
  end

  def create
    @news_feed  = request_user.news_feeds.new(news_feed_parmas)
    if @news_feed.save
     render json: {
       code: 200,
       success: true,
       message: 'News feed successfully created.',
       data: nil
     }
    else
      render json: {
        code: 400,
        success: false,
        message: @news_feed.errors.full_messages,
        data: nil
      }
    end
  end

  def update
    @news_feed  = NewsFeed.find(params[:id])
    if @news_feed.update!(news_feed_parmas)
    flash[:notice] = "News feed successfully updated."
     redirect_to admin_news_feeds_path
    else
      render :new
    end
  end

  def destroy
   if @news_feed.destroy
    flash[:notice] = "News feed successfully removed."
    redirect_to admin_news_feeds_path 
  else
    flash[:alert_danger] = "News feed removal failed."
    redirect_to admin_news_feeds_path
   end
  end

  def show
   
  end

  def edit

  end



  private

  def news_feed_parmas
  params.permit(:title, :description, :image, :user_id) 
 end

 def set_news_feed
  @news_feed = NewsFeed.find(params[:id])
 end
end
