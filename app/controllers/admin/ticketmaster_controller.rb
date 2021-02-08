# class Admin::TicketmasterController < Admin::AdminMasterController
#   require 'ticketmaster-sdk'
#   require 'json'

#    def select_date
  
#    end

#   def import_events
#     api_params = {page: 1, size: '20',  source: 'ticketmaster'}
#     client = Ticketmaster.client(apikey: 'FKZOvHgRcGGIRvrH4C6OYthDEYuhXu8T')
#     response = client.search_events(params: api_params)
#     results = response.results
#     start_date = params[:start_date].to_s
#     end_date = params[:end_date].to_s
#     errors = []
#     dates = (start_date..end_date).to_a.select {|k| k }
#     @events = results.map { |key|
#        if(dates.include?(key.dates['start']['localDate']))
#          if key != nil || key != false
#           event = Event.new
#           event.user = current_user
#           event.title = key.name.to_s
#           event.description = key.name.to_s
#           event.remote_image_url = key.images[8].url
#           event.start_date = key.dates['start']['localDate']
#           event.end_date  = key.dates['start']['localDate']
#           event.event_type = 'ticketmaster'
#            = key.dates['start']['localTime']
#            = "Not specified"
#           event.host = get_full_name(current_user)
#           event.location = key.embedded["venues"][0]["city"]["name"] + "," + key.embedded["venues"][0]["state"]["name"] + "," + key.embedded["venues"][0]["country"]["name"]
#           if event.save
#             errors.push("Successfully saved.")
#           else
#             errors.push(event.errors.full_messages)
#          end
#        end
#       end
#         #  "name" => key.name.to_s,
#         # "image" => key.images[0].url,
#         # "date" => key.dates['start']['localDate'],
#         # "start_time" => key.dates['start']['localTime'],
#         # "end_time" => "",
#         # "city" => key.embedded["venues"][0]["city"]["name"],
#         # "latlong" => key.embedded["venues"][0]["location"],
#         # "location" =>  key.embedded["venues"][0]["city"]["name"] + "," + key.embedded["venues"][0]["state"]["name"] + "," + key.embedded["venues"][0]["country"]["name"]      
#   }

#    redirect_to admin_events_path
#    #render json: results
#   end
# end
