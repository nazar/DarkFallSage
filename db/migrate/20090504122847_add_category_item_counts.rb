class AddCategoryItemCounts < ActiveRecord::Migration
  def self.up
    add_column :categories, :item_counts, :integer, {:default => 0}
  end

  def self.down
    remove_column :categories, :item_counts
  end
end
