class CreateSocialMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :social_media do |t|
      t.integer :user_id, default: ''
      t.string :facebook, default: ''
      t.string :linkedin, default: ''
      t.string :twitter, default: ''
      t.string :snapchat, default: ''
      t.string :instagram, default: ''
      t.string :youtube, default: ''
      t.timestamps
    end
  end
end
