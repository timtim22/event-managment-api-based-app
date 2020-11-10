class CreateNewsFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :news_feeds do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.string :image

      t.timestamps
    end
  end
end
