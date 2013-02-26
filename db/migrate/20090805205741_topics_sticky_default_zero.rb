class TopicsStickyDefaultZero < ActiveRecord::Migration
  def self.up
    change_column :topics, :sticky, :string, :default => 0
    Topic.update_all('sticky=0')
  end

  def self.down
    change_column :topics, :sticky, :string, :default => 0
  end
end
