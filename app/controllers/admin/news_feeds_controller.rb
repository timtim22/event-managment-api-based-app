class Admin::NewsFeedsController < Admin::AdminMasterController

  before_action :set_news_feed, only: ['show','edit', 'destroy']

  def index
    @news_feeds = current_user.news_feeds.order(:created_at => 'DESC').page(params[:page])
  end


  def new
    @news_feed = NewsFeed.new
  end

  def create
    @news_feed  = current_user.news_feeds.new(news_feed_parmas)
    if @news_feed.save
    flash[:notice] = "News feed successfully created."
     redirect_to admin_news_feeds_path
    else
      render :new
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
