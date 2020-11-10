class Admin::GmapController < Admin::AdminMasterController
  require 'json'

  def getLatLong
   name = params['name'].gsub(' ','+')
   if !name.blank?
    clnt = HTTPClient.new
    url = "https://maps.google.com/maps/api/geocode/json?address=#{name}&key=#{ENV['GMAP_API_KEY']}";
    json_data = clnt.get_content(url)
    results    = JSON.parse(json_data);
    if results['status'] != 'ZERO_RESULTS' 
        #  data  = results['results'][0]['geometry']['location']
         render json: {
            code: 200,
            success: true,
            message: "",
            data: results,
            addr: name
         }
    else 
      render json: {
        code: 200,
        success: false,
        message: 'Wrong location name.',
        data: nil
     }
    end
  end
  end

  # def getLatLong
  #   name = params['name'].gsub(' ','+')
  #   @client = GooglePlaces::Client.new(ENV['GMAP_API_KEY'])
  #   search = @client.spot(name)
  #   render json:search 
  # end

end
