class ItemMarkersCountCache < ActiveRecord::Migration
  def self.up
    add_column :items, :markers_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :items, :markers_count
  end
end
