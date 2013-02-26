class TopicsCountClanForums < ActiveRecord::Migration

  def self.up
    add_column :clan_forums, :topics_count, :integer, {:default => 0}
    add_column :clan_forums, :posts_count, :integer, {:default => 0}
    add_column :clan_forums, :description, :text
    add_column :clan_forums, :last_posted, :datetime
  end

  def self.down
    remove_column :clan_forums, :topics_count
    remove_column :clan_forums, :posts_count
    remove_column :clan_forums, :description
    remove_column :clan_forums, :last_posted
  end
end
