class TopicableAbilityColumns < ActiveRecord::Migration
  def self.up
    add_column :abilities, :last_posted,  :datetime
    add_column :abilities, :posts_count,  :integer, {:default => 0}
    add_column :abilities, :topics_count, :datetime, {:default => 0}
  end

  def self.down
    remove_column :abilities, :last_posted
    remove_column :abilities, :posts_count
    remove_column :abilities, :topics_count
  end
end
