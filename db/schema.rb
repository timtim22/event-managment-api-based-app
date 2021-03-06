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

ActiveRecord::Schema.define(version: 2021_04_22_115332) do

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
    t.index ["resource_id", "resource_type"], name: "index_activity_logs_on_resource_id_and_resource_type"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "admin_requests", force: :cascade do |t|
    t.string "status", default: ""
    t.integer "user_id"
    t.integer "admin_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "name", default: ""
  end

  create_table "ambassador_requests", force: :cascade do |t|
    t.integer "user_id"
    t.integer "business_id"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_ambassador_requests_on_business_id"
    t.index ["business_id"], name: "index_ambassador_requests_on_business_id_and_business_id"
    t.index ["user_id"], name: "index_ambassador_requests_on_user_id"
    t.index ["user_id"], name: "index_ambassador_requests_on_user_id_and_user_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_assignments_on_role_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "business_profiles", force: :cascade do |t|
    t.integer "user_id"
    t.string "profile_name", default: ""
    t.string "contact_name", default: ""
    t.string "website", default: ""
    t.string "vat_number", default: ""
    t.string "charity_number", default: ""
    t.boolean "is_charity", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.string "stripe_state", default: "rendom_string"
    t.string "connected_account_id", default: ""
    t.string "description", default: ""
    t.index ["user_id"], name: "index_business_profiles_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color_code"
    t.string "icon"
    t.string "uuid"
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

  create_table "child_events", force: :cascade do |t|
    t.integer "event_id"
    t.string "title", default: ""
    t.datetime "terms_conditions"
    t.text "description", default: ""
    t.string "location", default: ""
    t.boolean "over_18", default: true
    t.boolean "event_forwarding", default: false
    t.boolean "allow_chat", default: true
    t.boolean "allow_additional_media", default: true
    t.string "image", default: ""
    t.string "event_type", default: "public"
    t.string "price_type", default: ""
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.decimal "start_price", precision: 8, scale: 2, default: "0.0"
    t.decimal "end_price", precision: 8, scale: 2, default: "0.0"
    t.boolean "is_cancelled", default: false
    t.boolean "is_private", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pass", default: "false"
    t.integer "user_id"
    t.integer "quantity"
    t.integer "first_cat_id"
    t.string "location_name", default: "no_location"
    t.string "venue", default: ""
    t.string "status", default: ""
    t.datetime "start_time"
    t.datetime "end_time"
    t.index ["event_id"], name: "index_child_events_on_event_id"
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
    t.integer "child_event_id"
    t.index ["event_id"], name: "index_comments_on_event_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "competition_winners", force: :cascade do |t|
    t.integer "user_id"
    t.integer "competition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_competition_winners_on_user_id"
  end

  create_table "competitions", force: :cascade do |t|
    t.integer "user_id"
    t.string "title", default: ""
    t.text "description", default: ""
    t.string "image", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "terms_conditions", default: ""
    t.boolean "over_18", default: true
    t.integer "number_of_winner"
    t.boolean "competition_forwarding", default: false
    t.string "status", default: ""
    t.datetime "draw_time"
    t.index ["user_id"], name: "index_competitions_on_user_id"
  end

  create_table "event_attachments", force: :cascade do |t|
    t.integer "event_id"
    t.string "media"
    t.string "media_type", default: "0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_attachments_on_event_id"
  end

  create_table "event_dates", force: :cascade do |t|
    t.integer "event_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_forwardings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "child_event_id"
    t.index ["event_id"], name: "index_event_forwardings_on_event_id"
    t.index ["user_id"], name: "index_event_forwardings_on_user_id"
  end

  create_table "event_shares", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "child_event_id"
    t.index ["event_id"], name: "index_event_shares_on_event_id"
    t.index ["user_id"], name: "index_event_shares_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "user_id"
    t.string "title", default: ""
    t.text "description", default: ""
    t.string "location", default: ""
    t.boolean "over_18", default: true
    t.boolean "event_forwarding", default: false
    t.boolean "allow_chat", default: true
    t.boolean "allow_additional_media", default: true
    t.string "image", default: ""
    t.string "event_type", default: "public"
    t.string "price_type", default: ""
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.decimal "start_price", precision: 8, scale: 2, default: "0.0"
    t.decimal "end_price", precision: 8, scale: 2, default: "0.0"
    t.boolean "is_cancelled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "terms_conditions", default: ""
    t.boolean "price_range", default: false
    t.boolean "has_passes", default: false
    t.string "pass", default: "false"
    t.integer "first_cat_id"
    t.string "video"
    t.string "status", default: "active"
    t.boolean "is_repetive", default: false
    t.string "frequency", default: "daily"
    t.integer "max_attendees", default: 1
    t.integer "quantity"
    t.string "location_name", default: "no_location"
    t.string "redeem_code", default: ""
    t.string "venue", default: ""
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "qr_code", default: ""
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "follow_requests", force: :cascade do |t|
    t.integer "sender_id"
    t.string "sender_name"
    t.string "sender_avatar"
    t.integer "recipient_id"
    t.boolean "status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_follow_requests_on_recipient_id"
    t.index ["sender_id"], name: "index_follow_requests_on_sender_id"
  end

  create_table "follows", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "following_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: false
    t.index ["following_id"], name: "index_follows_on_following_id"
    t.index ["following_id"], name: "index_follows_on_following_id_and_following_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
    t.index ["user_id"], name: "index_follows_on_user_id_and_user_id"
  end

  create_table "friend_requests", force: :cascade do |t|
    t.string "status"
    t.integer "user_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.index ["friend_id"], name: "index_friend_requests_on_friend_id"
    t.index ["friend_id"], name: "index_friend_requests_on_friend_id_and_friend_id"
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
    t.integer "child_event_id"
    t.integer "ticket_id"
    t.index ["event_id", "user_id"], name: "index_interest_levels_on_event_id_and_user_id"
    t.index ["event_id"], name: "index_interest_levels_on_event_id"
    t.index ["user_id"], name: "index_interest_levels_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "user_id"
    t.decimal "amount", precision: 8, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 8, scale: 2, default: "0.0"
    t.string "tax_invoice_number"
    t.integer "total_tickets"
    t.decimal "vat_amount", precision: 8, scale: 2, default: "0.0"
    t.integer "event_id"
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
    t.index ["notification_id"], name: "index_location_shares_on_notification_id"
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
    t.string "message_type", default: "text"
    t.string "image", default: ""
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "news_feeds", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.text "description"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_news_feeds_on_user_id"
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
    t.integer "resource_id"
    t.string "resource_type"
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "offer_forwardings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.string "offer_type"
    t.integer "offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_ambassador", default: false
    t.index ["offer_id", "offer_type"], name: "index_offer_forwardings_on_offer_id_and_offer_type"
    t.index ["recipient_id"], name: "index_offer_forwardings_on_recipient_id"
    t.index ["user_id"], name: "index_offer_forwardings_on_user_id"
  end

  create_table "offer_shares", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipient_id"
    t.string "offer_type"
    t.integer "offer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_ambassador", default: false
    t.integer "business_id"
    t.index ["offer_id", "offer_type"], name: "index_offer_shares_on_offer_id_and_offer_type"
    t.index ["user_id"], name: "index_offer_shares_on_user_id"
  end

  create_table "outlets", force: :cascade do |t|
    t.integer "special_offer_id"
    t.string "outlet_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["special_offer_id"], name: "index_outlets_on_special_offer_id"
  end

  create_table "passes", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.string "title", default: ""
    t.text "description", default: ""
    t.datetime "validity"
    t.integer "ambassador_rate", default: 1
    t.integer "quantity", default: 1
    t.string "pass_type", default: "guest_pass"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "per_head"
    t.index ["event_id"], name: "index_passes_on_event_id"
    t.index ["user_id"], name: "index_passes_on_user_id"
  end

  create_table "password_resets", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_password_resets_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id"
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.datetime "dob"
    t.string "gender", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_online", default: false
    t.datetime "last_seen"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "redemptions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "offer_id"
    t.string "offer_type"
    t.integer "code", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id", "offer_type"], name: "index_redemptions_on_offer_id_and_offer_type"
    t.index ["user_id"], name: "index_redemptions_on_user_id"
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
    t.index ["ticket_id"], name: "index_refund_requests_on_ticket_id"
    t.index ["user_id"], name: "index_refund_requests_on_user_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "event_type"], name: "index_registrations_on_event_id_and_event_type"
    t.index ["event_id", "user_id"], name: "index_registrations_on_event_id_and_user_id"
    t.index ["user_id"], name: "index_registrations_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "level"
    t.integer "child_event_id"
    t.index ["event_id"], name: "index_reminders_on_event_id"
    t.index ["user_id"], name: "index_reminders_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.string "msg"
    t.integer "user_id"
    t.integer "comment_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reply_to_id"
    t.integer "child_event_id"
    t.index ["comment_id"], name: "index_replies_on_comment_id"
    t.index ["reply_to_id"], name: "index_replies_on_reply_to_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "reported_events", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "ticket_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reserved_for_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.boolean "is_on", default: true
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "social_media", force: :cascade do |t|
    t.integer "user_id"
    t.string "facebook", default: ""
    t.string "linkedin", default: ""
    t.string "twitter", default: ""
    t.string "snapchat", default: ""
    t.string "instagram", default: ""
    t.string "youtube", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "spotify", default: ""
  end

  create_table "special_offers", force: :cascade do |t|
    t.integer "user_id"
    t.string "title", default: ""
    t.string "sub_title", default: ""
    t.string "image", default: ""
    t.date "validity"
    t.text "description", default: ""
    t.string "location", default: ""
    t.string "lat", default: ""
    t.string "lng", default: ""
    t.integer "ambassador_rate", default: 1
    t.text "terms_conditions", default: ""
    t.boolean "agreed_to_terms", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.string "qr_code", default: ""
    t.boolean "over_18", default: true
    t.boolean "limited", default: true
    t.string "status", default: ""
    t.datetime "start_time"
    t.datetime "end_time"
    t.index ["user_id"], name: "index_special_offers_on_user_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.integer "event_id"
    t.string "sponsor_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_url"
    t.index ["event_id"], name: "index_sponsors_on_event_id"
  end

  create_table "ticket_purchases", force: :cascade do |t|
    t.integer "user_id"
    t.integer "ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.index ["ticket_id"], name: "index_ticket_purchases_on_ticket_id"
    t.index ["user_id"], name: "index_ticket_purchases_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.string "title", default: ""
    t.string "ticket_type", default: "buy"
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.integer "quantity", default: 1
    t.integer "per_head", default: 1
    t.decimal "start_price", precision: 8, scale: 2, default: "0.0"
    t.decimal "end_price", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "terms_conditions", default: ""
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
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
    t.index ["payee_id"], name: "index_transactions_on_payee_id"
    t.index ["ticket_id"], name: "index_transactions_on_ticket_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
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
    t.index ["resource_id", "resource_type"], name: "index_user_settings_on_resource_id_and_resource_type"
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "avatar", default: "avatar.png"
    t.string "phone_number", default: ""
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_subscribed"
    t.string "device_token", default: "no_token"
    t.string "about", default: ""
    t.string "location", default: ""
    t.string "uuid", default: ""
    t.boolean "mobile_user", default: true
    t.boolean "location_enabled", default: false
    t.string "status", default: ""
    t.string "phone_details", default: ""
  end

  create_table "views", force: :cascade do |t|
    t.integer "user_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "business_id"
    t.index ["resource_id", "resource_type"], name: "index_views_on_resource_id_and_resource_type"
    t.index ["user_id"], name: "index_views_on_competition_id_and_user_id"
    t.index ["user_id"], name: "index_views_on_event_id_and_user_id"
    t.index ["user_id"], name: "index_views_on_pass_id_and_user_id"
    t.index ["user_id"], name: "index_views_on_special_offer_id_and_user_id"
    t.index ["user_id"], name: "index_views_on_user_id"
  end

  create_table "vip_pass_shares", force: :cascade do |t|
    t.integer "pass_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pass_id"], name: "index_vip_pass_shares_on_pass_id"
    t.index ["user_id"], name: "index_vip_pass_shares_on_user_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.integer "offer_id"
    t.integer "user_id"
    t.string "offer_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_removed", default: false
    t.boolean "is_redeemed", default: false
    t.integer "quantity", default: 1
    t.index ["offer_id", "offer_type"], name: "index_wallets_on_offer_id_and_offer_type"
    t.index ["user_id"], name: "index_wallets_on_user_id"
    t.index [nil, "user_id"], name: "index_wallets_on_pass_id_and_user_id"
    t.index [nil, "user_id"], name: "index_wallets_on_special_offer_id_and_user_id"
  end

end
