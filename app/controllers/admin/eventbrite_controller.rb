class Admin::EventbriteController < Admin::AdminMasterController
require 'json'
def authorize_page
  render :authorize
end

  def authorize_user
    redirect_uri = request.domain == 'localhost:3000'? 'http://localhost:3000/admin/oauth/authorize' : "http://ec2-34-247-166-108.eu-west-1.compute.amazonaws.com:3001/admin/oauth/authorize"
    clnt = HTTPClient.new
    url = "https://www.eventbrite.com/oauth/token"
    #   header = [['content-type', 'application/x-www-form-urlencoded'], ['Accept', 'image/png']]
    header = { 'content-type' => 'application/x-www-form-urlencoded' }
    body = { 'grant_type' => 'authorization_code', 'client_id' => 'J7Y34HZ67LBQBCERPC', 'client_secret' => 'CGUZ4OJ5UYPV3Z5HW44RQHEW5QI2AHNKI5S6BPTNAPB7TB6M5R', 'code' => params[:code], 'redirect_uri' => redirect_uri }
   
   res = clnt.post(url, body, header)
   token = JSON.parse(res.content)['access_token'] 
   @user = current_user
   @user.eventbrite_token = token
   @user.save()
   redirect_to admin_import_events_path
end

def import_events
  token = current_user.eventbrite_token
  @events = [] 
  @categories = Category.all
   header = [['Content-Type', 'application/json'], ['Authorization', "Bearer #{current_user.eventbrite_token}"]]
  
  results = EventbriteSDK::User.me.owned_events.page(1, api_token: token)
  EventbriteSDK.token = token
  events = results.each do  |key|
    @events << {
      "name" => key.name.text.to_s,
      "description" => key.description.text,
      'image_url' => key.logo != nil ? key.logo["original"]["url"] : ' ',
      'eventbrite_url' => key.url,
      'image' => key.logo != nil ? key.logo["original"]["url"] : ' ',
      'start_date' => key.start["local"].split("T", 2)[0],
      'end_date' => key.end['local'].split("T",2)[0],
      'start_time' => key.start['local'].split("T",2)[1],
      "end_time" => key.end["local"].split("T",2)[1],
      "venue_id" => key.venue_id,
      'category_id' => key.category_id,
      'host' => get_full_name(current_user)
      # 'lat' => getLocation(key.venue_id,header)['latitude'],
      # 'lng' => getLocation(key.venue_id,header)['longitude']
    }
end

end

def store_imported
   if @event = Event.create!(:name => params['name'],description: params['description'], eventbrite_image: params['eventbrite_image'], image: params[:image], start_date: params['start_date'], end_date: params['end_date'], start_time: params['start_time'], end_time: params['end_time'], user: current_user, event_type: 'eventbrite',location: params['location'], host: params['host'], lat: params['lat'], lng: params['lng'])
    if !params[:event_attachments].blank?
      params[:event_attachments]['media'].each do |m|
        @event_attachment = @event.event_attachments.new(:media => m,:event_id => @event.id, media_type: 'image')
        @event_attachment.save
       end
      end #if
    render json: {
      code: 200,
      param: params,
      success: true,
      message: "imported successfully.",
      data:nil
    }
   else
    render json: {
      code: 400,
      success: false,
      message: @event.errors.full_messages,
      data:nil
    }
  end
end

def get_venue
  venue_id = params[:venue_id]
  clnt = HTTPClient.new
  header = [['Content-Type', 'application/json'], ['Authorization', "Bearer #{current_user.eventbrite_token}"]]
  if JSON.parse(clnt.get("https://www.eventbriteapi.com/v3/venues/#{venue_id}/",'', header).content)["address"] != nil
   @location = JSON.parse(clnt.get("https://www.eventbriteapi.com/v3/venues/#{venue_id}/",'', header).content)["address"]
  else
   @location = ''
  end
  render json: {
    code: 200,
    success: true,
    message: '',
    data:  {
      venue: @location
    }
  }
end

def get_category
  category_id = params[:category_id]
  clnt = HTTPClient.new
  header = [['Content-Type', 'application/json'], ['Authorization', "Bearer #{current_user.eventbrite_token}"]]
  if JSON.parse(clnt.get("https://www.eventbriteapi.com/v3/categories/#{category_id}/",'', header).content)["address"] != nil
   @cat = JSON.parse(clnt.get("https://www.eventbriteapi.com/v3/categories/#{category_id}/",'', header).content)
  else
   @cat = ''
  end
  render json: {
    code: 200,
    success: true,
    message: '',
    data:  {
      category: @cat,
      id: category_id
    }
  }
end

private 
def getLocation(venue_id,header)
  clnt = HTTPClient.new
 if JSON.parse(clnt.get("https://www.eventbriteapi.com/v3/venues/#{venue_id}/",'', header).content)["address"] != nil
  @location = JSON.parse(clnt.get("https://www.eventbriteapi.com/v3/venues/#{venue_id}/",'', header).content)["address"]
 else
  @location = ''
 end
end

end
