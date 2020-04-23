class User < ApplicationRecord
  has_secure_password(validations: false) 
  has_many :messages, dependent: :destroy
  has_one :assignment, dependent: :destroy
  has_many :events, dependent: :destroy
  has_one :role, through: :assignment
  has_one :student_detail, dependent: :destroy
  has_one :business_detail, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :friend_requests, dependent: :destroy
  has_many :accepted_friend_requests, -> {where(status: 'accepted') }, foreign_key: :friend_id, class_name: 'FriendRequest',dependent: :destroy
  has_many :friends, through: :accepted_friend_requests, source: :user
  
  has_many :chat_channels, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :followers_relationships, -> { where(status: true ) }, foreign_key: :following_id, class_name: 'Follow', dependent: :destroy 
  has_many :followers, through: :followers_relationships, source: :follower
  has_many :following_relationships, -> { where(status: true ) }, foreign_key: :user_id, class_name: "Follow", dependent: :destroy
  has_many :followings, through: :following_relationships, source: :following
  has_many :follow_requests, foreign_key: :recipient_id, class_name: 'FollowRequest', dependent: :destroy
  has_many :interest_levels, dependent: :destroy
  has_many :interested_interest_levels, -> { where(level:'interested') }, foreign_key: :user_id, class_name: 'InterestLevel', dependent: :destroy
  has_many :interested_in_events, through: :interested_interest_levels, source: :event
  has_many :passes, dependent: :destroy
  has_many :special_offers, dependent: :destroy
  has_many :own_competitions, dependent: :destroy, foreign_key: :user_id, class_name: 'Competition'
  has_many :wallets, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  has_many :registrations
  has_many :competitions
  has_many :competitions_to_attend, through: :registrations, source: :event, :source_type => "Competition" 
  has_many :going_interest_levels, -> { where(level: 'going') }, foreign_key: :user_id, class_name: 'InterestLevel', dependent: :destroy
  has_many :events_to_attend, through: :going_interest_levels, source: :event
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
  has_many :ticket_purchases, dependent: :destroy
  has_many :tickets, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :phone_number, presence: true, uniqueness: true,on: :create,
  :length => { :minimum => 10, :maximum => 15 }, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/ }
  validates :dob, presence:true
  validates :password, :presence => true,
                       :confirmation => true,
                       :on => :create,
                       :length => {:within => 6..40},
                       :unless => :app_user?
  

  # validates :email, presence: true, uniqueness: true
  # validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
 
  mount_uploader :avatar, ImageUploader
  mount_base64_uploader :avatar, ImageUploader
  
  #validate :password_for_web

  def self.authenticate(email,password) 
      user = User.find_by(email: email)
      user && user.authenticate(password)
  end

  def self.friend_requests(user)
    requests = FriendRequest.where(friend_id: user.id).where(status: 'pending').order(:created_at => "DESC")
  end
  
  def self.get_full_name(user)
    name = user.first_name + " " + user.last_name
  end

end
