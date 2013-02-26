class TopicsLockedDefaultZero < ActiveRecord::Migration
  def self.up
    change_column :topics, :locked, :string, :default => 0
    Topic.update_all('locked=0')
  end

  def self.down
    change_column :topics, :locked, :string, :default => 0
  end
end
