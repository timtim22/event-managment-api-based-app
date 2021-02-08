Rails.application.routes.draw do

  apipie
  resources :users
  resources :events
  get '/verify-phone' => "users#verify_phone_page"
  post '/verify-phone' => "users#verify_phone"
  post '/send_message' => 'chats#send_message'
  get '/privacy-policy' => 'users#privacy_policy'
 resources :chats
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
 namespace :api do
     namespace :v1 do
 
      namespace :users do
          resources :users, param: :email
            post '/update-profile' => 'users#update_profile'
            get '/get-profile' => 'users#get_profile'
            post '/get-profile' => "users#get_others_profile"
            post '/get-latlng' => 'gmap#getLatLong'
            post "/delete-account" => "users#delete_account"
            post '/update-device-token' => "users#update_device_token"
            get '/get-activity-logs' => "users#get_activity_logs"
            post '/update-current-location' => "users#update_current_location"       
            post '/update-profile-picture' => 'users#update_profile_pictures'
            post '/user-activity-logs' => 'users#activity_logs'
            get '/privacy-policy' => 'users#privacy_policy'
            get '/get-phone-numbers' => 'users#get_phone_numbers'
            get 'my-activity-logs' => 'users#my_activity_logs'
            get '/get-profile' => "users#get_business_profile"
            post '/get-profile' => "users#get_others_business_profile"

          namespace :settings do
            post '/update' => 'settings#update_global_setting'
            post '/update-user-setting' => 'settings#update_user_setting'
            post "/change-location-status" => "settings#change_location_status"
          end

          namespace :auth do
            post '/login', to: 'authentication#login'
            post '/logout', to: 'authentication#logout'
            post '/update-password', to: 'authentication#update_password'
            post '/get-accounts' => 'authentication#get_accounts'
          end

      end #users


      namespace :business do
        post '/get-offer-stats' => 'business_dashboard#get_offer_stats'
        post '/get-business-newsfeeds' => 'business_dashboard#get_business_news_feeds'
        post '/get-competition-stats' => 'business_dashboard#get_competition_stats' 
        post "/get-event-stats" => "business_dashboard#get_event_stats"
        post '/events/show' => 'business_dashboard#show_event'
        get '/get-dashbord' => 'business_dashboard#home'
        get '/get-events' => 'business_dashboard#events'
        get '/get-special-offers' => 'business_dashboard#special_offers'
        get '/get-competitions' => 'business_dashboard#competitions'
      end


      namespace :events do
          post "/events" => "events#index"
          post  "/get-map-events" =>  "events#get_map_events"
          post '/report-event' =>  "events#report_event"
          post '/create-event' =>  "events#create_view"
          post '/get-business-events' =>  "events#get_business_events"
          get '/map-event-list' => 'events#map_event_list'
          get '/categories' => "categories#index"
          post '/show' => 'events#show_event'
          
          namespace :passes do
            post '/get-list' => 'passes#index'
            post '/create-impression' => "passes#create_view"
            post "/single" => "passes#pass_single"
            post "/redemm-pass" => "passes#redeem_it"
          end

          namespace :tickets do
            post '/redeem' => "tickets#redeem_it"
            post '/get-tickets' => 'tickets#get_tickets'
          end
      
      end #event


      namespace :bookings do
        post '/create-interest' => "interest_levels#create_interest"
        post '/create-going' => "interest_levels#create_going"
        post '/purchase-ticket' => 'payments#purchase_ticket'
        post '/create-payment-intent' => 'payments#create_payment_intent'
        post '/confirm-payment' => 'payments#confirm_payment'
        post '/place-refund-request' => 'payments#place_refund_request'
      end


      namespace :specia_offers do
        post '/create-impression' => "special_offers#create_impression"
        post '/redeem' => "special_offers#redeem_it"
        post '/show' => "special_offers#show"
        post "/single" => "special_offers#special_offer_single"
      end #special_offers


     namespace :competitions do
        get '/get-list' => "competitions#index"
        post '/enter' => "competitions#register"
        get '/get-winner' => 'competitions#get_winner_and_notify'
        post '/create-impression' => "competitions#create_view"
        post "/single" => "competitions#competition_single"
     end 

    namespace :chats do
      post '/post-comment' => "comments#create"
      get '/get-commented-events' => "comments#get_commented_events"
      post '/send-message', to: 'chats#send_message'
      post '/history', to: 'chats#chat_history'
      get '/chat-people', to: 'chats#chat_people'
      post '/mark-as-read' => "chats#mark_as_read"
      post '/comments/mark-as-read' => "comments#mark_as_read"
      post '/clear-conversation' => 'chats#clear_conversation'
      post '/clear-chat' => 'chats#clear_chat'
      post '/delete-event-comments' => 'comments#delete_event_comments'

      post '/comments' => "comments#comments"
    end


   namespace :notifications do
     post "/read" => "notifications#read_notification"
     get '/send-events-reminder' => "notifications#send_events_reminder"
     get '/get-list' => "notifications#index"
     get '/mark-as-read' => "notifications#mark_as_read"
     post '/delete' => "notifications#delete_notification"
   end

   namespace :friendship do
      post '/send-request' => "friendships#send_request"
      # post '/check-request' => "friendships#check_request"
      get '/friend-requests' => "friendships#friend_requests"
      post '/accept-request' => "friendships#accept_request"
      post '/decline-request' => "friendships#remove_request"
      post '/remove-friend' => "friendships#remove_friend"
      get '/my-friends' => "friendships#my_friends"
      get '/suggest-friends' => 'friendships#suggest_friends'
      post '/get-friends-details' => 'friendships#get_friends_details'
  end


   namespace :ambassadors do
     get '/get-list' => 'ambassadors#ambassadors_requets'
     get '/approve' => 'ambassadors#approve'
     get '/remove' => 'ambassadors#remove'
     get '/view' => 'ambassadors#view_ambassador'
     post '/attending' => 'users#attending'
     post '/gives-away' => 'users#gives_away'
     get '/my-gives-away' => 'users#my_gives_away'
     get '/my-attending' => 'users#my_attending'
     post '/send-request' => "ambassadors#send_request"
     get '/businesses-list' => "ambassadors#businesses_list"
     get '/my-businesses' => "ambassadors#my_businesses"
   end


   namespace :follows do
     get '/my-followings' => "follows#my_followings"
     post '/follow' => "follows#follow"
     post '/unfollow' => "follows#unfollow"
     post '/remove-follow-request' => 'follows#remove_request'
     post '/remove-follower' => 'follows#remove_follower'
     post '/follow/accept-request' => "follows#accept_request"
     get '/follow/requests' => "follows#requests_list"
     get '/follow-requests' => "follows#requests_list"
     get '/accept-request' => "follows#accept_request"
     get '/my-followers' => "follows#followers"
     get '/suggest-businesses' => 'follows#suggest_businesses'
   end


   namespace :share do
     post '/ask-location' => "notifications#ask_location"
     post '/get-location' => "notifications#get_location"
     post '/send-location' => "notifications#send_location"
     post '/forward-offer' => "forwarding#forward_offer"
     post '/share-offer' => "forwarding#share_offer"
     post '/events/share' => 'forwarding#share_event'
     post '/events/forward' => 'forwarding#forward_event'
   end


   namespace :wallets do
     get '/get-offers' => 'wallets#get_offers'
     get '/get-passes' => 'wallets#get_passes'
     get '/get-competitions' => 'wallets#get_competitions'
     get '/get-tickets' => 'wallets#get_tickets'
     post '/remove-offer' => 'wallets#remove_offer'
     post '/add-to-wallet' => 'wallets#add_to_wallet'
     post '/view-offer' => "wallets#view_offer"
   end


    post "/create-impression" => "api_master#create_impression"
    post "/search/global-search" => "search#global_search"
    get '/search' => 'search#events_live_search'

      #  get '/publish', to: 'chat#publish'
      #  get '/subscribe', to: 'chat#subscribe'
      #  post '/events-by-date', to: 'events#events_list_by_date'
      #  post '/events/create-impression' => 'events#create_impression'
      #  get '/get-wallet' => "wallets#get_wallet"
      #  get '/get-users-having-common-fields' => 'users#get_users_having_common_fields'
      # get '/*a', to: 'application#not_found'
     end
   end

#==================================================================================================
#==================================================================================================

   get 'send-email' => 'contact_form#send_email'
   namespace :admin do
     get 'dashboard' => 'dashboard#index'
     get 'user/get-profile' => 'users#get_profile'
     post '/user/update-password' => "users#update_password"
     get '/reset-password' => 'users#send_email_page'
     post '/send-reset-email' => 'users#send_reset_email'
     get  '/reset-password-page' => 'users#reset_password_page'
     post '/reset-password' => 'users#reset_password'
     post '/user/update-avatar' => "users#update_avatar"
     post '/user/update-info' => 'users#update_info'
     get '/user/search-friends' => 'search#search_friends'
     get '/user/add-friends-page' => 'search#add_friends_page'
    
    #  get '/eventbrite-authorize' => "eventbrite#authorize_page"
    #  get "/import/events" => "eventbrite#import_events"
    #  get '/oauth/authorize' => "eventbrite#authorize_user"

    #  get '/ticketmaster/import-events' => "ticketmaster#select_date"
    #  post '/ticketmaster/import-events' => "ticketmaster#import_events"
   
     post '/eventbrite/get-venue' => "eventbrite#get_venue"
     post '/eventbrite/get-category' => "eventbrite#get_category"
     post '/eventbrite/store-imported' => "eventbrite#store_imported"
     get '/view-activity' => "users#view_activity"
    
     get '/add-payment-account' => 'payments#add_payment_account'
     get '/stripe/oauth' => 'payments#stripe_oauth_redirect'
     get '/payments/received-payments' => "payments#received_payments"
     delete '/payments/delete' => "payments#delete_payment"
     get '/payments/refund-requests' => "payments#refund_requests"
     get '/payments/approve-refund' => "payments#approve_refund"
     get '/payments/reject-refund' => "payments#reject_refund"
     get '/send-vip-pass' => "passes#send_vip_pass_page"
     post '/send-vip-pass' => "passes#send_vip_pass"
     post '/delete-resource' => 'events#delete_resource'

     resources :news_feeds
     resources :categories

     resources :events do
       resources :comments
     end

     resources :transactions, :controller => "payments"
     resources :users
     resources :roles
     resource :session
     resources :passes
     resources :special_offers
     resources :competitions
     resources :tickets

   end

#=======================================================================================================================================================================================================
   namespace :dashboard do
    namespace :api do
      namespace :v1 do

      namespace :users do
        post '/update-user' => 'users#update_user'
        post '/create-user' => 'users#create_user'
        get '/show-all-users' => 'users#show_all_users'
        post '/get-user' => 'users#get_user'
        post '/auth/login', to: 'authentication#login'
      end

        resources :news_feeds
        resources :invoices

        resources :events do
          resources :comments
        end

        resources :competitions
        patch 'dashboard/api/v1/competitions/:id', to: 'competition#update'
        resources :special_offers
        get "/get-my-events" => "events#get_my_events"
        post "/delete-resource" => "events#delete_resource"
        post '/send-verification-code', to: 'users#send_verification_code'
        get  '/get-followers' => 'users#get_followers'
        get '/get-past-events' => 'events#get_past_events'
        get '/get-past-offers' => 'special_offers#get_past_offers'
        get '/get-past-competitions' => 'competitions#get_past_competitions'
        post '/passes/send-vip-pass' => 'passes#send_vip_pass'
        get '/passes/vip-people' => 'passes#vip_people'
        post '/passes/remove-vip-pass' => 'passes#remove_vip_pass'
        get '/get-app-users' => 'users#get_app_users'
        post '/get-user' => 'users#get_user'
        get '/get-categories' => 'events#get_categories'
        post '/cancel-event' => 'events#cancel_event'
        post '/delete-event' => 'events#delete_event'
        post '/payments/create-intant' => 'payments#create_intant'
        post '/payments/confirm-payment' => 'payments#confirm_payment'
        post '/payments/get-invoice' => 'payments#get_invoice'
        post '/get-dashboard-stats' => 'dashboard#get_dashboard_stats'
        post '/get-parent-event-stats' => 'dashboard#get_parent_event_stats'
        post '/get-child-event-stats' => 'dashboard#get_child_event_stats'
        post '/attendees-stats' => 'dashboard#get_child_event_attendees_stats'
        post '/attendees-live-stats' => 'dashboard#get_live_event_data'
        post '/vip-pass-users' => 'passes#vip_pass_users'
        post '/search-users' => 'passes#search_users'
        post '/delete-vip-pass' => 'passes#delete_vip_pass'
      end
    end
   end

   namespace :business do
   end

   namespace :college_society do
   end

 end
