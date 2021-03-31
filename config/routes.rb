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
            resources :users
            get '/get-list' => 'users#index'
            post '/create-user' => 'users#create_user'
            post '/update-profile' => 'users#update_profile'
            post '/get-profile' => "users#get_profile"
            post "/delete-account" => "users#delete_account"
            post '/update-device-token' => "users#update_device_token"
            get '/get-activity-logs' => "users#get_activity_logs"
            post '/update-current-location' => "users#update_current_location"       
            post '/update-profile-picture' => 'users#update_profile_pictures'
            post '/activity-logs' => 'users#activity_logs'
            get '/privacy-policy' => 'users#privacy_policy'
            get '/get-phone-numbers' => 'users#get_phone_numbers'
            get '/activity-logs' => 'users#my_activity_logs'
            post '/attending' => 'users#attending'
            get '/attending' => 'users#my_attending'

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


      namespace :businesses do
        post '/get-offer-stats' => 'analytics#get_offer_stats'
        post '/get-competition-stats' => 'analytics#get_competition_stats' 
        post "/get-event-stats" => "analytics#get_event_stats"
        post '/get-news-feeds' => 'business_dashboard#get_business_news_feeds'
        post '/events/show' => 'business_dashboard#show_event'
        get '/get-dashboard' => 'business_dashboard#home'
        post '/get-events' => 'business_dashboard#get_events'
        post '/get-special-offers' => 'business_dashboard#get_special_offers'
        post '/get-competitions' => 'business_dashboard#get_competitions'
      end


      namespace :bookings do
        post '/create-interest' => "interest_levels#create_interest"
        post '/create-going' => "interest_levels#create_going"
        post '/purchase-ticket' => 'payments#purchase_ticket'
        post '/create-payment-intent' => 'payments#create_payment_intent'
        post '/confirm-payment' => 'payments#confirm_payment'
        post '/place-refund-request' => 'payments#place_refund_request'
       
      end


      namespace :events do
          post "/get-list" => "events#index"
          post  "/get-map-events" =>  "events#get_map_events"
          post '/report-event' =>  "events#report_event"
          post '/create-event' =>  "events#create_view"
          post '/create-impression' =>  "events#create_impression"
          get '/map-event-list' => 'events#map_event_list'
          get '/categories' => "categories#index"
          post '/show' => 'events#show_event'
          
          namespace :passes do
            post '/get-list' => 'passes#index'
            post '/create-impression' => "passes#create_impression"
            post "/show" => "passes#pass_single"
            post "/redeem" => "passes#redeem_it"
          end

          namespace :tickets do
            post '/redeem' => "tickets#redeem_it"
            post '/get-list' => 'tickets#get_tickets'
            post '/create-reservation' => 'reservations#create'
          end

          namespace :comments do
            post '/post' => "comments#create"
            get '/get-commented-events' => "comments#get_commented_events"
            post '/comments-mark-as-read' => "comments#mark_as_read"
            post '/delete' => 'comments#delete_event_comments'
            post '/comments' => "comments#get_event_comments"
          end
      
      end #events



      namespace :special_offers do
        get '/get-list' => "special_offers#get_list"
        post '/create-impression' => "special_offers#create_impression"
        post '/redeem' => "special_offers#redeem_it"
        post '/show' => "special_offers#show" 
      end #special_offers


     namespace :competitions do
        get '/get-list' => "competitions#index"
        post '/enter' => "competitions#register"
        get '/get-winner' => 'competitions#get_winner_and_notify'
        post '/create-impression' => "competitions#create_view"
        post "/single" => "competitions#competition_single"
        post "/businesses-competitions" => "competitions#get_business_competitions"
     end 

    namespace :chats do
      post '/send-message', to: 'chats#send_message'
      post '/history', to: 'chats#chat_history'
      get '/chat-people', to: 'chats#chat_people'
      post '/mark-as-read' => "chats#mark_as_read"
      post '/clear-conversation' => 'chats#clear_conversation'
      post '/clear-chat' => 'chats#clear_chat'
    end



   namespace :notifications do
     get '/get-list' => "notifications#index"
     post "/read" => "notifications#read"
     post '/delete' => "notifications#delete"
     get '/mark-as-read' => "notifications#mark_as_read" 
   end


   namespace :friendship do
      post '/send-request' => "friendships#send_request"
      # post '/check-request' => "friendships#check_request"
      get '/friend-requests' => "friendships#friend_requests"
      post '/accept-request' => "friendships#accept_request"
      post '/remove-request' => "friendships#remove_request"
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
     post '/send-request' => "ambassadors#send_request"
     get '/businesses-list' => "ambassadors#businesses_list"
     get '/my-businesses' => "ambassadors#my_businesses"
     post '/gives-away' => 'ambassadors#gives_away'
     get '/gives-away' => 'ambassadors#my_gives_away'
   end


   namespace :follows do
     get '/my-followings' => "follows#my_followings"
     post '/follow' => "follows#follow"
     post '/unfollow' => "follows#unfollow"
     get '/my-followers' => "follows#my_followers"
     get '/suggest-businesses' => 'follows#suggest_businesses'
    #  post '/remove-follow-request' => 'follows#remove_request'
    #  post '/remove-follower' => 'follows#remove_follower'
    #  get '/follow/requests' => "follows#requests_list"
    #  get '/follow-requests' => "follows#requests_list"
    #  get '/accept-request' => "follows#accept_request"
     
   end


   namespace :share do
     post '/ask-location' => "forwarding#ask_location"
     post '/get-location' => "forwarding#get_location"
     post '/send-location' => "forwarding#send_location"
     post '/forward-offer' => "forwarding#forward_offer"
     post '/share-offer' => "forwarding#share_offer"
     post '/share-event' => 'forwarding#share_event'
     post '/forward-event' => 'forwarding#forward_event'
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
    post '/get-latlng' => 'gmap#getLatLong'

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
  get '/add-friend' => "friendships#send_request"
  get '/check-request' => "friendships#check_request"
  get '/friend-requests' => "friendships#friend_requests"
  get '/accept-request' => "friendships#accept_request"
  get '/my-friends' => "friendships#my_friends"
  get '/eventbrite-authorize' => "eventbrite#authorize_page"
  get "/import/events" => "eventbrite#import_events"
  get '/oauth/authorize' => "eventbrite#authorize_user"

  get '/ticketmaster/import-events' => "ticketmaster#select_date"
  post '/ticketmaster/import-events' => "ticketmaster#import_events"
  get '/get-notificatons' => "notifications#index"
  get '/get-notifications-count' => "notifications#get_notifications_count"
  get '/mark-as-read' => "notifications#mark_as_read"
  get '/clear-notifications' => "notifications#clear_notifications"
  post '/get-latlng' => 'gmap#getLatLong'
  get '/follow-requests' => "follows#requests_list"
  get '/accept-follow-request' => "follows#accept_request"
  get '/my-followers' => "follows#followers"
  post '/eventbrite/get-venue' => "eventbrite#get_venue"
  post '/eventbrite/get-category' => "eventbrite#get_category"
  post '/eventbrite/store-imported' => "eventbrite#store_imported"
  get '/view-activity' => "users#view_activity"
  get '/ambassadors' => 'ambassadors#ambassadors_requets'
  get '/ambassadors/approve' => 'ambassadors#approve'
  get '/ambassadors/remove' => 'ambassadors#remove'
  get '/ambassadors/view' => 'ambassadors#view_ambassador'
  get '/add-payment-account' => 'payments#add_payment_account'
  get '/stripe/oauth' => 'payments#stripe_oauth_redirect'
  get '/payments/received-payments' => "payments#received_payments"
  delete '/payments/delete' => "payments#delete_payment"
  get '/payments/refund-requests' => "payments#refund_requests"
  get '/payments/approve-refund' => "payments#approve_refund"
  get '/payments/reject-refund' => "payments#reject_refund"
  get '/send-vip-pass' => "passes#send_vip_pass_page"
  post '/send-vip-pass' => "passes#send_vip_pass"
  

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
        post '/business-type', to: 'users#business_type'
        post '/add-image', to: 'users#add_image'
        post '/add-details', to: 'users#add_details'
        post '/add-login', to: 'users#add_login'
        post '/add-social', to: 'users#add_social'
        post '/add-phone', to: 'users#add_phone'
        post '/link-accounts', to: 'users#link_accounts'
        post '/invite-admin', to: 'users#invite_admin'
        post '/accept-admin-request', to: 'users#accept_admin_request'
        post '/admin-requests', to: 'users#admin_requests'
        post '/get-device-token', to: 'users#get_device_token'
        get '/get-user', to: 'users#get_user'

          namespace :auth do
            post '/login', to: 'authentication#login'
          end
      end

      namespace :events do
        post '/create-event' => 'events#create_event'
        post '/add-time' => 'events#add_times'
        post '/add-resource' => 'events#add_admission_resource'
        post '/add-sponsor' => 'events#add_sponsor'
        post '/add-media' => 'events#add_media'
        post '/add-social' => 'events#add_social'
        get '/get-categories' => 'events#get_categories'
        get '/get-list' => 'events#index'
        post '/publish-event' => 'events#publish_event'
        post '/show' => 'events#show'
        post '/delete-resource' => 'events#delete_resource'
        post '/delete-event' => 'events#delete_event'
        post '/cancel-event' => 'events#cancel_event'
      end

        resources :news_feeds
        resources :invoices

        resources :events do
          resources :comments
        end

        resources :competitions
        patch 'dashboard/api/v1/competitions/:id', to: 'competition#update'
        
        resources :special_offers

        namespace :special_offers do
         post "/add-image" => "special_offers#add_image"
         post "/add-details" => "special_offers#add_details"
         post "/add-time" => "special_offers#add_time"
         post "/add-outlets" => "special_offers#add_outlets"
         post "/remove-outlet" => "special_offers#remove_outlet"
         post "/terms-conditions" => "special_offers#terms_conditions"
         post "/ambassador-rate" => "special_offers#ambassador_rate"
         post "/publish-offer" => "special_offers#publish_offer"
        end

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


 end
