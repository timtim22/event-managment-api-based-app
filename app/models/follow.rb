class Follow < ApplicationRecord
  require 'date'
  belongs_to :follower, foreign_key: 'user_id', class_name: "User"
  belongs_to :following, foreign_key: 'following_id', class_name: "User"
  has_many :activity_logs, dependent: :destroy, as: :resource
  # belongs_to :follow_request
  # scope :monthly_followers_count, lambda {|user, now, one_moth_before| where("created_at >= ? AND created_at <= ? && following_id = ?", start_date, end_date, user.id ).size}

  def self.this_month_followers_count(user_id)
    now = DateTime.now
    days = now.strftime('%d').to_i - 1
    start = (now - days) 
    start_date = start.strftime("%Y-%m-%d %H:%M:%S")
    end_date = now.strftime("%Y-%m-%d %H:%M:%S")
    follows = Follow.where("created_at >= '#{start_date}' AND created_at <= '#{end_date}' AND following_id = #{user_id}").size
  end
end
