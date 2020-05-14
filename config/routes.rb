Rails.application.routes.draw do
  resources :users
  resources :events
  get '/verify-phone' => "users#verify_phone_page"
  post '/verify-phone' => "users#verify_phone"
  post '/send_message' => 'chats#send_message'
 
 resources :chats
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
 namespace :api do
     namespace :v1 do
       resources :users, param: :email
       resources :events
       resources :special_offers 
       post '/auth/login', to: 'authentication#login'
       post '/auth/logout', to: 'authentication#logout'
       post '/auth/send-verification-email', to: 'authentication#send_verification_email'
       post '/auth/verify-code', to: 'authentication#verify_code'
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
       get '/get-notifications' => "notifications#index"
       get '/mark-as-read' => "notifications#mark_as_read"
       get '/send-events-reminder' => "notifications#send_events_reminder"
       post '/update-device-token' => "users#update_device_token"
       post '/chat/clear-conversation' => 'chats#clear_conversation'
       post '/ambassadors/send-request' => "ambassadors#send_request"
       get '/ambassadors/businesses-list' => "ambassadors#businesses_list"
       get '/ambassadors/my-businesses' => "ambassadors#my_businesses"
       post '/update-current-location' => "users#update_current_location"
       post '/forward-offer' => "notifications#forward_offer"
       post '/share-offer' => "notifications#share_offer"
       post '/view-offer' => "wallets#view_offer"
       post '/events/report-event' =>  "events#report_event"
       post '/events/update-setting' => "events#update_setting"
       post '/events/purchase-ticket' => 'payments#purchase_ticket'
       post '/payments/get-secret' => 'payments#get_secret'
       post '/payments/confirm-payment' => 'payments#confirm_payment'
     
      # get '/*a', to: 'applic ation#not_found'
     end
   end
   get 'send-email' => 'contact_form#send_email'
   namespace :admin do
     get 'dashboard' => 'dashboard#index'
     get 'user/get-profile' => 'users#get_profile'
     post '/user/update-password' => "users#update_password"
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
     get '/get-notificaitons' => "notifications#index"
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
 
   namespace :business do
   end
 
   namespace :college_society do
   end
   
 end
 