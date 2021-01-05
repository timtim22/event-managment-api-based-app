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
       resources :users, param: :email
       resource :passes
       #resources :events
       resources :special_offers
       post "/events" => "events#index"
       get '/categories' => "categories#index"
       post '/auth/login', to: 'authentication#login'
       post '/auth/logout', to: 'authentication#logout'
       post '/auth/send-verification-email', to: 'authentication#send_verification_email'
       get '/auth/verify-code', to: 'authentication#verify_code'
       post '/auth/update-password', to: 'authentication#update_password'
       post '/chat/send-message', to: 'chats#send_message'
       post '/chat/chat-history', to: 'chats#chat_history'
       get '/chat/chat-people', to: 'chats#chat_people'
       get '/publish', to: 'chat#publish'
       get '/subscribe', to: 'chat#subscribe'
       post '/events-by-date', to: 'events#events_list_by_date'
       post '/user/update-profile' => 'users#update_profile'
       get '/user/get-profile' => 'users#get_profile'
       post '/user/get-others-profile' => "users#get_others_profile"
       get '/user/get-business-profile' => "users#get_business_profile"
       post '/user/get-others-business-profile' => "users#get_others_business_profile"
       post '/add-friend' => "friendships#send_request"
       post '/check-request' => "friendships#check_request"
       get '/friend-requests' => "friendships#friend_requests"
       post '/accept-request' => "friendships#accept_request"
       post '/remove-request' => "friendships#remove_request"
       post '/remove-friend' => "friendships#remove_friend"
       get '/my-friends' => "friendships#my_friends"
       post '/event/post-comment' => "comments#create"
       get '/event/get-commented-events' => "comments#get_commented_events"
       post '/event/comments' => "comments#comments"
       get '/event/followers' => "follows#followers"
       get '/event/followings' => "follows#followings"
       post '/event/follow' => "follows#follow"
       post '/event/unfollow' => "follows#unfollow"
       post '/event/remove-follow-request' => 'follows#remove_request'
       post '/event/remove-follower' => 'follows#remove_follower'
       post '/event/follow/accept-request' => "follows#accept_request"
       get '/event/follow/requests' => "follows#requests_list"
       post '/event/create-interest' => "interest_levels#create_interest"
       post '/event/create-going' => "interest_levels#create_going"
       post '/event/redeem-pass' => "passes#redeem_it"
       post '/events/create-view' => 'events#create_view'
       post '/redeem-special-offer' => "special_offers#redeem_it"
       post '/event/redeem-ticket' => "tickets#redeem_it"
       get '/competitions' => "competitions#index"
       post '/competitions/register' => "competitions#register"
       post '/add-to-wallet' => 'wallets#add_to_wallet'
       get '/get-wallet' => "wallets#get_wallet"
       get '/get-activity-logs' => "users#get_activity_logs"
       post '/ask-location' => "notifications#ask_location"
       post '/get-location' => "notifications#get_location"
       post '/send-location' => "notifications#send_location"
       get '/notifications/get-notifications' => "notifications#index"
       get '/notifications/mark-as-read' => "notifications#mark_as_read"
       post '/notifications/delete-notification' => "notifications#delete_notification"
       post '/chats/mark-as-read' => "chats#mark_as_read"
       post '/comments/mark-as-read' => "comments#mark_as_read"
       get '/send-events-reminder' => "notifications#send_events_reminder"
       post '/update-device-token' => "users#update_device_token"
       post '/chat/clear-conversation' => 'chats#clear_conversation'
       post '/chat/clear-chat' => 'chats#clear_chat'
       post '/comments/delete-event-comments' => 'comments#delete_event_comments'
       post '/ambassadors/send-request' => "ambassadors#send_request"
       get '/ambassadors/businesses-list' => "ambassadors#businesses_list"
       get '/ambassadors/my-businesses' => "ambassadors#my_businesses"
       post '/update-current-location' => "users#update_current_location"
       post '/forward-offer' => "forwarding#forward_offer"
       post '/share-offer' => "forwarding#share_offer"
       post '/view-offer' => "wallets#view_offer"
       post '/events/report-event' =>  "events#report_event"
       post '/settings/update' => 'settings#update_global_setting'
       post '/settings/update-user-setting' => 'settings#update_user_setting'
       post '/events/purchase-ticket' => 'payments#purchase_ticket'
       post '/payments/get-secret' => 'payments#get_secret'
       post '/payments/confirm-payment' => 'payments#confirm_payment'
       post '/payments/place-refund-request' => 'payments#place_refund_request'
       post '/analytics/get-dashboard' => 'analytics#get_dashboard'
       post '/analytics/get-offer-stats' => 'analytics#get_offer_stats'
       post '/analytics/get-competition-stats' => 'analytics#get_competition_stats'
       post '/events/share' => 'forwarding#share_event'
       post '/events/forward' => 'forwarding#forward_event'
       get '/competitions/get-winner' => 'competitions#get_winner_and_notify'
       get '/friendships/suggest-friends' => 'friendships#suggest_friends'
       get '/follows/suggest-businesses' => 'follows#suggest_businesses'
       post '/special_offers/create-view' => "special_offers#create_view"
       post '/passes/create-view' => "passes#create_view"
       post '/competitions/create-view' => "competitions#create_view"
       get '/get-users-having-common-fields' => 'users#get_users_having_common_fields'
       get '/privacy-policy' => 'users#privacy_policy'
       post '/friendships/get-friends-details' => 'friendships#get_friends_details'
       post '/get-accounts' => 'authentication#get_accounts'
       get '/get-business-dashbord' => 'business_dashboard#home'
       get '/get-business-events' => 'business_dashboard#events'
       get '/get-business-special-offers' => 'business_dashboard#special_offers'
       get '/get-business-competitions' => 'business_dashboard#competitions'
       get '/get-phone-numbers' => 'users#get_phone_numbers'
       post '/events/show' => 'events#show_event'
       get '/events/map-event-list' => 'events#map_event_list'
       get '/events/search' => 'search#events_live_search'
       post '/events/passes' => 'passes#index'
       get 'wallet/get-offers' => 'wallets#get_offers'
       get 'wallet/get-passes' => 'wallets#get_passes'
       get 'wallet/get-competitions' => 'wallets#get_competitions'
       get 'wallet/get-tickets' => 'wallets#get_tickets'
       post 'wallet/remove-offer' => 'wallets#remove_offer'
       post 'get-business-events' => 'events#get_business_events'
       post 'get-business-offers' => 'special_offers#get_business_special_offers'
       post 'get-business-competitions' => 'competitions#get_business_competitions'
       post 'get-business-news-feeds' => 'business_dashboard#get_business_news_feeds'
       post 'event/get-tickets' => 'tickets#get_tickets'
       post 'payments/get-stripe-params' => 'payments#get_stripe_params'
       post 'users/update-profile-picture' => 'users#update_profile_pictures'
       post 'user-activity-logs' => 'users#activity_logs'
       post 'user-attending' => 'users#attending'
       post 'user-gives-away' => 'users#gives_away'
       get 'my-gives-away' => 'users#my_gives_away'
       get 'my-attending' => 'users#my_attending'
       get 'my-activity-logs' => 'users#my_activity_logs'
       post 'special_offers/show' => "special_offers#show"
       post "special-offers/special-offer-single" => "special_offers#special_offer_single"
       post "passes/pass-single" => "passes#pass_single"
       post "competitions/competition-single" => "competitions#competition_single"
       post "notifications/read" => "notifications#read_notification"
       post  "events/get-map-events" =>  "events#get_map_events"
       post "settings/change-location-status" => "settings#change_location_status"
       post "users/delete-account" => "users#delete_account"
       post "/search/global-search" => "search#global_search"



      # get '/*a', to: 'application#not_found'
     end
   end
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

   namespace :dashboard do
    namespace :api do
      namespace :v1 do

        resources :users
        patch 'dashboard/api/v1/users/:id', to: 'user#update'

        resources :news_feeds
        resources :invoices

        resources :events do
          resources :comments
        end

        resources :competitions

        patch 'dashboard/api/v1/competitions/:id', to: 'competition#update'



        resources :special_offers
        get "/get-my-events" => "events#get_my_events"
        post '/auth/login', to: 'authentication#login'
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



        get '/get-dashboard-stats' => 'dashboard#get_dashboard_stats'

      end
    end
   end

   namespace :business do
   end



   namespace :college_society do
   end

 end
