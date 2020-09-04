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
    @news_feed = NewsFeed.find(params[:id])
    if @news_feed.update!(news_feed_parmas)
     render json:  {
       code: 200,
       success:true,
       message: 'News feed successfully updated.',
       data: {
         news_feed: @news_feed
       }
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



  def destroy
   if @news_feed.destroy
    render json:  {
       code: 200,
       success:true,
       message: 'News feed successfully deleted.',
       data: nil
     }
  else
    render json: {
      code: 400,
      success: false,
      message: "News feed deletion failed.",
      data: nil
    }
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
