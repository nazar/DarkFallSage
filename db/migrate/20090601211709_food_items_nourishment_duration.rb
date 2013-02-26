class FoodItemsNourishmentDuration < ActiveRecord::Migration
  def self.up
    add_column :items, :nourishment_duration, :float, {:default => 0}
  end

  def self.down
    remove_column :items, :nourishment_duration
  end
end
