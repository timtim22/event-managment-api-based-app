class  Admin::SearchController < Admin::AdminMasterController
  before_action :force_json, only: [:search_friends]
 
  def add_friends_page
    render  :add_friends
  end
   
  def search_friends 
    @q = User.ransack(first_name_cont: params[:q])
    @friends = @q.result(distinct: true)
  end

  private 
   def force_json
     request.format = :json
   end
end
 