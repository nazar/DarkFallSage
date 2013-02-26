class ImageCountsOnObjects < ActiveRecord::Migration

  def self.up
    add_column :items, :images_count, :integer, {:default => 0}
    add_column :spells, :images_count, :integer, {:default => 0}
    add_column :skills, :images_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :items, :images_count
    remove_column :spells, :images_count
    remove_column :skills, :images_count
  end
end
