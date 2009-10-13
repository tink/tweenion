class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.references :event
      t.string :title
      t.text :description
      t.string :tag
      t.integer :neutral, :default => 0
      t.integer :positive, :default => 0
      t.integer :negative, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
