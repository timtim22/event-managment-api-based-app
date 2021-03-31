class Dashboard::Api::V1::NewsFeeds::NewsFeedsController < Dashboard::Api::V1::ApiMasterController

  before_action :set_news_feed, only: ['show','edit', 'destroy']

    resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/news_feeds', 'Get all news feeds'

  def index
    @news_feeds = request_user.news_feeds.page(params[:page]).per(20).order(:created_at => 'DESC').page(params[:page])
    render json: {
      code: 200,
      success: true,
      message:'',
      data: {
        news_feeds: @news_feeds
      }
    }
  end


  def new
    @news_feed = NewsFeed.new
  end

  api :POST, 'dashboard/api/v1/news_feeds', 'Create a news feed'
  param :user_id, :number, :desc => "User ID", :required => true
  param :title, String, :desc => "Title of the news feed", :required => true
  param :description, String, :desc => "Description of the news feed", :required => true
  param :image, String, :desc => "Image of the competition", :required => true

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

  api :POST, 'dashboard/api/v1/news_feeds', 'Create a news feed'
  param :id, :number, :desc => "ID of a news feed", :required => true
  param :user_id, :number, :desc => "User ID", :required => true
  param :title, String, :desc => "Title of the news feed", :required => true
  param :description, String, :desc => "Description of the news feed", :required => true
  param :image, String, :desc => "Image of the competition", :required => true

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

  api :DELETE, 'dashboard/api/v1/news_feeds', 'Delete a news feed'
  param :id, :number, :desc => "ID of a news feed", :required => true

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
