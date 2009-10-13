class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :tag
      t.string :last_tweet_id
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
