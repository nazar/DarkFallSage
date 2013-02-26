class TopicableItemsColumns < ActiveRecord::Migration
  def self.up
    add_column :items, :last_posted,  :datetime
    add_column :items, :posts_count,  :integer, {:default => 0}
    add_column :items, :topics_count, :datetime, {:default => 0}
  end

  def self.down
    remove_column :items, :last_posted
    remove_column :items, :posts_count
    remove_column :items, :topics_count
  end
end
