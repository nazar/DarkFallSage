class MoreItemProtections < ActiveRecord::Migration

  def self.up
    add_column :items, :protect_holy, :float
    add_column :items, :protect_impact, :float
    add_column :items, :protect_unholy, :float
    add_column :items, :restore_health, :float
    add_column :items, :restore_mana, :float
  end

  def self.down
    remove_column :items, :protect_holy
    remove_column :items, :protect_impact
    remove_column :items, :protect_unholy
    remove_column :items, :restore_health
    remove_column :items, :restore_mana
  end
end
