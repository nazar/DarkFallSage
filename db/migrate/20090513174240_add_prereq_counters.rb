class AddPrereqCounters < ActiveRecord::Migration
  def self.up
    add_column :items, :required_count, :integer, {:default => 0}
    add_column :skills, :required_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :items, :required_count
    remove_column :skills, :required_count
  end
end
