class TopicsCountTypeChange < ActiveRecord::Migration
  def self.up
    change_column :skills, :topics_count, :integer, {:default => 0}
    change_column :items, :topics_count, :integer, {:default => 0}
    change_column :abilities, :topics_count, :integer, {:default => 0}
  end

  def self.down
    #nothing to see here
  end
end
