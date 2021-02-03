class User < ApplicationRecord
  has_secure_password(validations: false)

  has_many :messages, dependent: :destroy
  has_many :incoming_messages, foreign_key: :recipient_id, class_name: 'Message', dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :roles, through: :assignments
  has_many :events, dependent: :destroy
  has_many :child_events, dependent: :destroy
  has_one :student_detail, dependent: :destroy
  has_one :business_detail, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :friend_requests, dependent: :destroy
  has_many :redemptions, dependent: :destroy

  has_many :accepted_friend_requests, -> {where(status: 'accepted') }, foreign_key: :friend_id, class_name: 'FriendRequest',dependent: :destroy
  has_many :friends, through: :accepted_friend_requests, source: :user
  has_many :chat_channels, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :outgoing_notifications, foreign_key: :actor_id, class_name: 'Notification', dependent: :destroy
  has_many :followers_relationships, -> { where(status: true ) }, foreign_key: :following_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :followers_relationships, source: :follower
  has_many :following_relationships, -> { where(status: true ) }, foreign_key: :user_id, class_name: "Follow", dependent: :destroy
  has_many :followings, through: :following_relationships, source: :following
  has_many :follow_requests, foreign_key: :recipient_id, class_name: 'FollowRequest', dependent: :destroy
  has_many :interest_levels, dependent: :destroy
  has_many :interested_interest_levels, -> { where(level:'interested') }, foreign_key: :user_id, class_name: 'InterestLevel', dependent: :destroy
  has_many :interested_in_events, through: :interested_interest_levels, source: :child_event
  has_many :passes, dependent: :destroy
  has_many :special_offers, dependent: :destroy
  has_many :own_competitions, dependent: :destroy, foreign_key: :user_id, class_name: 'Competition'
  has_many :wallets, dependent: :destroy
  has_many :owned_passes, through: :wallets, source: :offer, source_type: "Pass"
  has_many :owned_special_offers, through: :wallets, source: :offer, source_type: "SpecialOffer"
  has_many :activity_logs, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :competitions, dependent: :destroy
  has_many :competitions_to_attend, through: :registrations, source: :event, :source_type => "Competition"
  has_many :going_interest_levels, -> { where(level: 'going') }, foreign_key: :user_id, class_name: 'InterestLevel', dependent: :destroy
  has_many :events_to_attend, through: :going_interest_levels, source: :child_event
  has_many :reminders, dependent: :destroy
  has_many :ambassador_requests, dependent: :destroy
  has_many :accepted_ambassador_requests, -> { where(status: 'accepted') }, foreign_key: :user_id, class_name: 'AmbassadorRequest', dependent: :destroy
  has_many :ambassador_businesses, through: :accepted_ambassador_requests, source: :business
  has_many :business_ambassador_requests, foreign_key: :business_id, class_name: 'AmbassadorRequest', dependent: :destroy
  has_many :approved_business_ambassador_requests, -> { where(status: 'accepted') }, foreign_key: :business_id, class_name: 'AmbassadorRequest', dependent: :destroy
  has_many :ambassadors, through: :approved_business_ambassador_requests, source: :user
  has_many :offer_forwardings, dependent: :destroy
  has_many :offer_shares, dependent: :destroy
  has_many :reported_events, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :to_me_replies, foreign_key: :reply_to_id, class_name: 'Reply', dependent: :destroy
  has_many :ticket_purchases, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :received_payments, foreign_key: :payee_id, class_name: 'Transaction', dependent: :destroy
  has_many :refund_requests, dependent: :destroy
  has_many :business_refund_requests, foreign_key: :business_id, class_name: 'RefundRequest', dependent: :destroy
  has_one :location_setting, -> { where(name: 'location') }, class_name: 'Setting', dependent: :destroy
  has_one :all_chat_notifications_setting, -> { where(name: 'all_chat_notifications') }, class_name: 'Setting', dependent: :destroy
  has_one :event_notifications_setting, -> { where(name: 'event_notifications') }, class_name: 'Setting', dependent: :destroy
  has_one :special_offers_notifications_setting, -> { where(name: 'special_offers_notifications') }, class_name: 'Setting', dependent: :destroy
  has_one :passes_notifications_setting, -> { where(name: 'passes_notifications') }, class_name: 'Setting', dependent: :destroy
  has_one :competitions_notifications_setting, -> { where(name: 'competitions_notifications') },  class_name: 'Setting', dependent: :destroy
  has_many  :mute_chat_for_events, -> { where(name: 'mute_chat', resource_type: 'Event') }, class_name: 'UserSetting', dependent: :destroy, source_type: :event
  has_many  :mute_notifications_for_events, -> { where(name: 'mute_notifications', resource_type: 'Event') }, class_name: 'UserSetting', dependent: :destroy, source_type: :event
  has_many  :block_events, -> { where(name: 'block', resource_type: 'Event') }, class_name: 'UserSetting', dependent: :destroy, source: :event
  has_many  :mute_chat_for_users, -> { where(name: 'mute_chat', resource_type: 'User') }, class_name: 'UserSetting', dependent: :destroy, source_type: :user
  has_many  :block_users, -> { where(name: 'block', resource_type: 'User')}, class_name: 'UserSetting', dependent: :destroy, source_type: :user
  has_many :remove_competitions, -> { where(name: 'remove_competitions', resource_type: 'Competition') },  class_name: 'UserSetting', source_type: :competition, dependent: :destroy
  has_many :remove_offers, -> { where(name: 'remove_offers', resource_type: 'SpecialOffer') }, class_name: 'UserSetting', source_type: :special_offer, dependent: :destroy
  has_many :remove_passes, -> { where(name: 'remove_passes', resource_type: 'Pass') }, class_name: 'UserSetting', source_type: :pass, dependent: :destroy
  has_many :remove_tickets, -> { where(name: 'remove_ticket', resource_type: 'Ticket') }, class_name: 'UserSetting', source_type: :pass, dependent: :destroy
  has_many :news_feeds, dependent: :destroy
  has_many :invoices, dependent: :destroy

  has_many :password_resets, dependent: :destroy
  has_many :event_shares, dependent: :destroy
  has_many :event_forwardings, dependent: :destroy
  has_many :views, dependent: :destroy
  has_many :business_views, foreign_key: "business_id", class_name: 'View', dependent: :destroy
  has_many :business_shares, foreign_key: "business_id", class_name: 'OfferShare', dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :user_settings, dependent: :destroy
  has_one :business_profile, dependent: :destroy
  has_one :social_medium, dependent: :destroy




  # validates :is_subscribed, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :create, if: :web_user

  validates :phone_number, presence: true, on: :create,
  :length => { :minimum => 10, :maximum => 15 }, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/ }

  validates :password, :presence => true,
                       :confirmation => true,
                       :on => :create,
                       :length => {:within => 8..40},
                       :format => {message: 'should contain at least one lower character and a special character.', with: /\A(?=.*[a-z])(?=.*[[:^alnum:]]) /x},
                       :unless => :app_user?



  mount_uploader :avatar, ImageUploader
  mount_base64_uploader :avatar, ImageUploader


  # scope :app_users, -> { where(app_user: true) }
  # scope :web_users, -> { where(web_user: true) }

  #validate :password_for_web

  def self.authenticate(email,password)
      user = User.find_by(email: email)
      user && user.authenticate(password)
  end

  def self.friend_requests(user)
    requests = FriendRequest.where(friend_id: user.id).where(status: 'pending').order(:created_at => "DESC")
  end

  def self.get_full_name(user)
    if user.app_user == true
     name = user.profile.first_name + " " + user.profile.last_name
    elsif(user.web_user ==  true)
      name = user.business_profile.profile_name
    end
  end

  def self.businesses_list
    businesses = []
    self.all.map {|user| if user.roles.map {|role| role.id }.include?  2 then businesses.push(user) end }
    businesses
  end

  def has_business_contact_name
    if BusinessProfile.contact_name.empty?
      errors.add(:contact, " is required field.")
    end
  end



end
