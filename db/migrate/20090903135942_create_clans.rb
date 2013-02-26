class CreateClans < ActiveRecord::Migration
  def self.up
    create_table :clans do |t|
      t.integer :owner_id, :access_type, :server 
      t.string :name, :limit => 100
      t.text :description, :charter
      t.integer :members_count, :forums_count, :topics_count, :posts_count, :default => 0
      t.timestamps
    end
    add_index :clans, :owner_id
  end

  def self.down
    drop_table :clans
  end
end