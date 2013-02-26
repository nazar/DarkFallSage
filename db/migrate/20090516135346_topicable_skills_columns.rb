class TopicableSkillsColumns < ActiveRecord::Migration
  def self.up
    add_column :skills, :last_posted,  :datetime
    add_column :skills, :posts_count,  :integer, {:default => 0}
    add_column :skills, :topics_count, :datetime, {:default => 0}
  end

  def self.down
    remove_column :skills, :last_posted
    remove_column :skills, :posts_count
    remove_column :skills, :topics_count
  end
end
