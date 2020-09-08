# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_08_120806) do

  create_table "activity_logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "browser"
    t.string "ip_address"
    t.string "action"
    t.string "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "resource_id"
    t.string "resource_type"
    t.string "resource_title"
    t.string "method"
    t.string "url"
    t.string "action_type"
  end

  create_table "ambassador_requests", force: :cascade do |t|
    t.integer "user_id"
    t.integer "business_id"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_assignments_on_role_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "business_details", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_business_details_on_user_id"
  end

  create_table "business_profiles", force: :cascade do |t|
    t.integer "user_id"
    t.string "address", default: ""
    t.string "website", default: ""
    t.text "about", default: ""
    t.string "vat_number", default: ""
    t.string "charity_number", default: ""
    t.string "twitter", default: ""
    t.string "facebook", default: ""
    t.string "linkedin", default: ""
    t.string "instagram", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_name"
    t.string "contact_name"
    t.boolean "is_charity", default: false
    t.boolean "is_ambassador", default: false
    t.string "snapchat", default: ""
    t.string "youtube", default: ""
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color_code"
    t.string "icon"
  end

  create_table "categorizations", force: :cascade do |t|
    t.integer "event_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["event_id"], name: "index_categorizations_on_event_id"
  end

  create_table "chat_channels", force: :cascade do |t|
    t.integer "recipient_id"
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "push_token"
    t.index ["user_id"], name: "index_chat_channels_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "comment"
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "from"
    t.string "user_avatar"
    t.datetime "read_at"
    t.integer "reader_id"
    t.index ["event_id"], name: "index_comments_on_event_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "competition_participants", force: :cascade do |t|
    t.string "user_id"
    t.string "ccompetition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "competition_winners", force: :cascade do |t|
    t.integer "user_id"
    t.integer "competition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "competitions", force: :cascade do |t|
    t.integer "user_id"
    t.string "title", default: ""
    t.text "description", default: ""
    t.string "image", default: ""
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "location", default: ""
    t.string "lat", default: ""
    t.string "lng", default: ""
    t.datetime "validity"
    t.string "price", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "host", default: ""
    t.string "placeholder", default: "http://placehold.it/900x300"
    t.datetime "validity_time"
  end

  create_table "event_attachments", force: :cascade do |t|
    t.integer "event_id"
    t.string "media"
    t.string "media_type", default: "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_forwardings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_shares", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "start_date"
    t.datetime "start_time"
    t.string "external_link"
    t.string "host", default: ""
    t.text "description", default: ""
    t.string "feature_media_link", default: ""
    t.string "additional_media", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location", default: ""
    t.boolean "over_18", default: false
    t.boolean "event_forwarding", default: false
    t.boolean "allow_chat", default: false
    t.boolean "allow_additional_media", default: false
    t.integer "invitees", default: 0
    t.string "image", default: ""
    t.string "placeholder", default: "http://placehold.it/900x300"
    t.datetime "end_time"
    t.integer "user_id"
    t.string "event_type", default: "public"
    t.datetime "end_date"
    t.string "price_type", default: "free"
    t.float "price", default: 0.0
    t.string "lat", default: ""
    t.string "lng", default: ""
    t.string "eventbrite_image", default: ""
    t.boolean "is_private", default: false
    t.boolean "is_cancelled", default: false
  end

  create_table "follow_requests", force: :cascade do |t|
    t.integer "sender_id"
    t.string "sender_name"
    t.string "sender_avatar"
    t.integer "recipient_id"
    t.boolean "status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "following_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: false
  end

  create_table "friend_requests", force: :cascade do |t|
    t.string "status"
    t.integer "user_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.index ["friend_id"], name: "index_friend_requests_on_friend_id"
    t.index ["user_id"], name: "index_friend_requests_on_user_id"
  end

  create_table "friends", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interest_levels", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.string "level", default: "0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "location_requests", force: :cascade do |t|
    t.integer "user_id"
    t.integer "askee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notification_id"
  end

  create_table "location_shares", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.string "lat", default: ""
    t.string "lng", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notification_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "recipient_id"
    t.text "message"
    t.datetime "read_at"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "from"
    t.string "user_avatar"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "news_feeds", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.text "description"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "actor_id"
    t.integer "notifiable_id"
    t.string "notifiable_type"
    t.text "data"
    t.string "action"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "notification_type"
    t.string "action_type"
  end

  create_table "offer_forwardings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.string "offer_type"
    t.integer "offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_ambassador", default: false
  end

  create_table "offer_shares", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.string "offer_type"
    t.integer "offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_ambassador", default: false
  end

  create_table "passes", force: :cascade do |t|
    t.string "title", default: ""
    t.text "description", default: ""
    t.datetime "validity"
    t.integer "event_id"
    t.string "redeem_code", default: "0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "is_redeemed", default: false
    t.text "terms_conditions", default: ""
    t.boolean "agreed_to_terms", default: false
    t.string "ambassador_name", default: ""
    t.datetime "validity_time"
    t.string "ambassador_rate", default: "1"
    t.integer "quantity", default: 1
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.string "pass_type", default: "ordinary"
  end

  create_table "password_resets", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "about", default: ""
    t.boolean "add_social_media_links", default: false
    t.string "facebook", default: ""
    t.string "twitter", default: ""
    t.string "snapchat", default: ""
    t.string "instagram", default: ""
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "linkedin", default: "Not connected"
    t.string "youtube", default: ""
    t.integer "ranking", default: 1
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "device_token", default: ""
    t.datetime "dob"
    t.string "gender", default: ""
    t.string "location", default: ""
    t.string "lat", default: ""
    t.string "lng", default: ""
    t.integer "earning", default: 0
    t.boolean "is_email_subscribed", default: false
    t.boolean "is_ambassador", default: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "redemptions", force: :cascade do |t|
    t.integer "user_id"
    t.string "offer_id"
    t.integer "code", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "offer_type"
  end

  create_table "refund_requests", force: :cascade do |t|
    t.integer "user_id"
    t.integer "business_id"
    t.integer "ticket_id"
    t.string "status", default: "pending"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "stripe_refund_response"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminders", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "level"
  end

# Could not dump table "replies" because of following StandardError
#   Unknown type '' for column 'msg'

  create_table "reported_events", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
    t.text "apn_key"
    t.string "apn_key_id"
    t.string "team_id"
    t.string "bundle_id"
    t.boolean "feedback_enabled", default: true
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string "device_token", limit: 64
    t.datetime "failed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer "badge"
    t.string "device_token", limit: 64
    t.string "sound"
    t.text "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_is_json", default: false, null: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.boolean "content_available", default: false, null: false
    t.text "notification"
    t.boolean "mutable_content", default: false, null: false
    t.string "external_device_id"
    t.string "thread_id"
    t.boolean "dry_run", default: false, null: false
    t.index ["app_id", "delivered", "failed", "deliver_after"], name: "index_rapns_notifications_multi"
    t.index ["delivered", "failed", "processing", "deliver_after", "created_at"], name: "index_rpush_notifications_multi", where: "NOT delivered AND NOT failed"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.boolean "is_on", default: true
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "special_offers", force: :cascade do |t|
    t.string "title", default: ""
    t.text "description", default: ""
    t.datetime "validity"
    t.text "terms_conditions", default: ""
    t.boolean "agreed_to_terms", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_redeemed", default: false
    t.string "redeem_code", default: ""
    t.string "sub_title", default: ""
    t.string "image", default: ""
    t.string "location", default: ""
    t.datetime "date"
    t.datetime "end_time"
    t.string "lat", default: ""
    t.string "lng", default: ""
    t.integer "user_id"
    t.datetime "time"
    t.string "ambassador_rate", default: "1"
  end

  create_table "sponsors", force: :cascade do |t|
    t.integer "event_id"
    t.string "name"
    t.string "sponsor_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_url"
  end

  create_table "student_details", force: :cascade do |t|
    t.string "university"
    t.string "email"
    t.string "student_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_student_details_on_user_id"
  end

  create_table "ticket_purchases", force: :cascade do |t|
    t.integer "user_id"
    t.integer "ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.string "ticket_type", default: "paid"
    t.integer "price", default: 0
    t.integer "quantity", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "per_head", default: 1
    t.string "title", default: ""
    t.float "start_price", default: 0.0
    t.float "end_price", default: 0.0
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "user_id"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "payment_intent"
    t.json "stripe_response"
    t.integer "ticket_id"
    t.integer "payee_id"
    t.integer "amount"
  end

  create_table "user_settings", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", default: "setting"
    t.integer "resource_id"
    t.boolean "is_on", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_type"
    t.datetime "blocked_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verification_code"
    t.string "avatar", default: "avatar.png"
    t.string "phone_number"
    t.boolean "app_user", default: false
    t.boolean "phone_verified", default: false
    t.string "stripe_state", default: "no state"
    t.string "connected_account_id", default: "no account"
    t.boolean "is_email_verified", default: false
    t.boolean "web_user", default: false
  end

  create_table "views", force: :cascade do |t|
    t.integer "user_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallets", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "user_id"
    t.string "offer_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
