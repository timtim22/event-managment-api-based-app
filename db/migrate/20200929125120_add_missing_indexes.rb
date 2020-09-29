class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :activity_logs, :user_id
    add_index :activity_logs, [:resource_id, :resource_type]
    add_index :ambassador_requests, :business_id
    add_index :ambassador_requests, :user_id
    add_index :ambassador_requests, [:business_id, :business_id]
    add_index :ambassador_requests, [:user_id, :user_id]
    add_index :business_profiles, :user_id
    add_index :competition_winners, :user_id
    add_index :event_attachments, :event_id
    add_index :event_forwardings, :event_id
    add_index :event_forwardings, :user_id
    add_index :event_shares, :event_id
    add_index :event_shares, :user_id
    add_index :follow_requests, :recipient_id
    add_index :follow_requests, :sender_id
    add_index :follows, :following_id
    add_index :follows, :user_id
    add_index :follows, [:following_id, :following_id]
    add_index :follows, [:user_id, :user_id]
    add_index :friend_requests, [:friend_id, :friend_id]
    add_index :interest_levels, :event_id
    add_index :interest_levels, :user_id
    add_index :interest_levels, [:event_id, :user_id]
    add_index :location_shares, :notification_id
    add_index :messages, :recipient_id
    add_index :news_feeds, :user_id
    add_index :notifications, :actor_id
    add_index :notifications, :recipient_id
    add_index :notifications, [:notifiable_id, :notifiable_type]
    add_index :offer_forwardings, :recipient_id
    add_index :offer_forwardings, :user_id
    add_index :offer_forwardings, [:offer_id, :offer_type]
    add_index :offer_shares, :user_id
    add_index :offer_shares, [:offer_id, :offer_type]
    add_index :password_resets, :user_id
    add_index :profiles, :user_id
    add_index :redemptions, :user_id
    add_index :redemptions, [:offer_id, :offer_type]
    add_index :refund_requests, :ticket_id
    add_index :refund_requests, :user_id
    add_index :registrations, :user_id
    add_index :registrations, [:event_id, :event_type]
    add_index :registrations, [:event_id, :user_id]
    add_index :reminders, :event_id
    add_index :reminders, :user_id
    add_index :replies, :comment_id
    add_index :replies, :reply_to_id
    add_index :replies, :user_id
    add_index :settings, :user_id
    add_index :special_offers, :user_id
    add_index :sponsors, :event_id
    add_index :ticket_purchases, :ticket_id
    add_index :ticket_purchases, :user_id
    add_index :transactions, :payee_id
    add_index :transactions, :ticket_id
    add_index :transactions, :user_id
    add_index :user_settings, :user_id
    add_index :user_settings, [:resource_id, :resource_type]
    add_index :views, :user_id
    add_index :views, [:competition_id, :user_id]
    add_index :views, [:event_id, :user_id]
    add_index :views, [:pass_id, :user_id]
    add_index :views, [:resource_id, :resource_type]
    add_index :views, [:special_offer_id, :user_id]
    add_index :vip_pass_shares, :pass_id
    add_index :vip_pass_shares, :user_id
    add_index :wallets, :user_id
    add_index :wallets, [:offer_id, :offer_type]
    add_index :wallets, [:pass_id, :user_id]
    add_index :wallets, [:special_offer_id, :user_id]
  end
end
